//
//  Ch13Camera.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 13: choosing cameras by the direction they face, on a phone
//  with two displays. Runs on a device; the simulator has no camera and
//  shows a placeholder instead.
//

import AVFoundation
import AVKit
import SwiftUI
import Synchronization

// iOS 27.1 symbols don't compile for Mac Catalyst in Xcode 27.1 beta
// (185924957); see Chapter 19.
#if !targetEnvironment(macCatalyst)

// MARK: - The capture actor

// snippet:begin ch13-capture-actor
/// Owns the capture session. All configuration happens on this actor,
/// off the main actor. The main actor hands it descriptors, which are
/// Sendable, never devices.
@available(iOS 27.1, *)
actor CaptureSession {
    /// The preview layer reads this once, on the main actor; only this
    /// actor ever configures it.
    nonisolated(unsafe) let session = AVCaptureSession()
    private var videoInput: AVCaptureDeviceInput?
    private let frames = AVCaptureVideoDataOutput()
    private let firstFrame = FirstFrameSignal()
    private let rotation = PreviewRotation()

    init() {
        let queue = DispatchQueue(label: "pro.ihor.unfolded.frames")
        frames.setSampleBufferDelegate(firstFrame, queue: queue)
    }

    /// Moves the one video input to the camera the descriptor names and
    /// makes a rotation coordinator for it. `rotate` receives preview
    /// angles on the main actor. Returns false if that camera is gone
    /// or doesn't fit.
    func selectCamera(
        _ camera: AVCaptureDeviceDescriptor,
        rotate: @escaping @MainActor @Sendable (CGFloat) -> Void
    ) throws -> Bool {
        // The set of cameras can change while a descriptor travels.
        guard let device = AVCaptureDevice(uniqueID: camera.uniqueID)
        else { return false }
        let newInput = try AVCaptureDeviceInput(device: device)

        session.beginConfiguration()
        defer { session.commitConfiguration() }
        if !session.outputs.contains(frames), session.canAddOutput(frames) {
            session.addOutput(frames)
        }
        if let videoInput {
            session.removeInput(videoInput)
        }
        guard session.canAddInput(newInput) else {
            if let videoInput { session.addInput(videoInput) }
            return false
        }
        firstFrame.expect(newInput)
        session.addInput(newInput)
        videoInput = newInput
        if let layer = session.connections.lazy
            .compactMap(\.videoPreviewLayer).first {
            rotation.track(device, in: layer, rotate: rotate)
        }
        return true
    }

    /// Returns once the input chosen last has delivered a frame.
    func waitForFirstFrame() async {
        await firstFrame.wait()
    }

    func start() {
        if !session.isRunning { session.startRunning() }
    }

    func stop() {
        if session.isRunning { session.stopRunning() }
        rotation.stop()
        firstFrame.releaseWaiters()
    }
}
// snippet:end ch13-capture-actor

/// Signals the first frame a given input delivers to a video data
/// output. Frames arrive on the output's queue, so the state sits
/// behind a lock.
final class FirstFrameSignal: NSObject, Sendable,
    AVCaptureVideoDataOutputSampleBufferDelegate {
    private struct State {
        var source: ObjectIdentifier?
        var hasFrame = false
        var waiters: [CheckedContinuation<Void, Never>] = []
    }

    private let state = Mutex(State())

    /// Waits for frames from `input` from now on.
    func expect(_ input: AVCaptureInput) {
        let source = ObjectIdentifier(input)
        state.withLock {
            $0.source = source
            $0.hasFrame = false
        }
    }

    func wait() async {
        await withCheckedContinuation { continuation in
            let hasFrame = state.withLock {
                if !$0.hasFrame { $0.waiters.append(continuation) }
                return $0.hasFrame
            }
            if hasFrame { continuation.resume() }
        }
    }

    /// Resumes every waiter, for example when capture stops.
    func releaseWaiters() {
        let waiters = state.withLock {
            defer { $0.waiters = [] }
            return $0.waiters
        }
        waiters.forEach { $0.resume() }
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // A frame still in flight from the old input doesn't count.
        let source = connection.inputPorts.first.map {
            ObjectIdentifier($0.input)
        }
        let waiters = state.withLock {
            guard !$0.hasFrame, source == $0.source else {
                return [CheckedContinuation<Void, Never>]()
            }
            $0.hasFrame = true
            defer { $0.waiters = [] }
            return $0.waiters
        }
        waiters.forEach { $0.resume() }
    }
}

// MARK: - The camera model

/// The main-actor side of the camera: directions, the active camera,
/// and everything that touches the preview layer.
@available(iOS 27.1, *)
@MainActor @Observable
final class CameraModel {
    let capture = CaptureSession()
    private(set) var activeCamera: AVCaptureDeviceDescriptor?
    private(set) var isSwitching = false
    private(set) var failure: String?
    var fillsDisplay = true {
        didSet { applyVideoGravity() }
    }

    @ObservationIgnored
    private var directionCoordinator: AVCaptureDeviceDirectionCoordinator?
    @ObservationIgnored private var directions: AVCaptureDeviceDirectionMap?
    @ObservationIgnored private var switchTask: Task<Void, Never>?
    @ObservationIgnored private weak var previewLayer: AVCaptureVideoPreviewLayer?

    /// Connects a preview view that has just joined a window.
    func attach(_ view: PreviewView) {
        previewLayer = view.previewLayer
        view.previewLayer.session = capture.session
        applyVideoGravity()
        observeDirections(for: view)
    }

    /// Lets go of the coordinator and stops capture when the preview
    /// leaves the screen. The next attach picks a camera again.
    func detach() {
        directionCoordinator = nil
        switchTask?.cancel()
        switchTask = nil
        isSwitching = false
        activeCamera = nil
        Task { await capture.stop() }
    }

    /// Crops to 16:9 where the active format allows it, and shows any
    /// error instead of dropping it.
    func useLandscapeAspectRatio() async {
        do {
            try await capture.useLandscapeAspectRatio()
        } catch {
            failure = error.localizedDescription
        }
    }
}

// snippet:begin ch13-direction-coordinator
@available(iOS 27.1, *)
extension CameraModel {
    /// Watches which cameras face the person looking at `previewView`.
    /// One coordinator per preview view, made on the main actor and kept
    /// alive while the view is on screen. It reports only the device
    /// types listed, so list every camera the app captures from.
    func observeDirections(for previewView: UIView) {
        directionCoordinator = AVCaptureDeviceDirectionCoordinator(
            view: previewView,
            deviceTypes: [
                .builtInOuterUltraWideCamera,  // iPhone Duo, front
                .builtInInnerUltraWideCamera,  // iPhone Duo, front
                .builtInUltraWideCamera,       // iPhone 17 front; rear
                .builtInWideAngleCamera,       // front and rear
                .builtInDualWideCamera,        // rear
            ]
        ) { [weak self] directions in
            // No AVFoundation calls here; hand the descriptors on.
            self?.directionsDidChange(directions)
        }
    }
}
// snippet:end ch13-direction-coordinator

// snippet:begin ch13-switch-input
@available(iOS 27.1, *)
extension CameraModel {
    /// Keeps one video input on a camera that faces the person. The
    /// preview is masked from the moment directions change until the
    /// new camera delivers its first frame. A newer change cancels an
    /// older switch, so only the latest one lifts the mask.
    func directionsDidChange(_ directions: AVCaptureDeviceDirectionMap) {
        self.directions = directions
        let forward = directions.forwardFacingDeviceDescriptors
        if let activeCamera, forward.contains(where: {
            $0.uniqueID == activeCamera.uniqueID
        }) {
            return  // Still facing the person: keep it.
        }
        guard let camera = forward.first else { return }

        let rotate: @MainActor @Sendable (CGFloat) -> Void = {
            [weak self] angle in self?.applyPreviewRotation(angle)
        }
        switchTask?.cancel()
        isSwitching = true
        switchTask = Task {
            defer { if !Task.isCancelled { isSwitching = false } }
            do {
                let moved = try await capture.selectCamera(
                    camera, rotate: rotate
                )
                guard moved, !Task.isCancelled else { return }
                activeCamera = camera
                cameraDidChange(to: camera, directions: directions)
                await capture.start()
                await capture.waitForFirstFrame()
            } catch {
                failure = error.localizedDescription
            }
        }
    }
}
// snippet:end ch13-switch-input

@available(iOS 27.1, *)
extension CameraModel {
    /// Reapplies what a new preview connection doesn't carry over.
    private func cameraDidChange(
        to camera: AVCaptureDeviceDescriptor,
        directions: AVCaptureDeviceDirectionMap
    ) {
        guard let connection = previewLayer?.connection else { return }
        applyMirroring(to: connection, for: camera, in: directions)
    }

    /// Turns the preview to the angle the rotation coordinator reports.
    private func applyPreviewRotation(_ angle: CGFloat) {
        guard let connection = previewLayer?.connection,
              connection.isVideoRotationAngleSupported(angle)
        else { return }
        connection.videoRotationAngle = angle
    }

    private func applyVideoGravity() {
        guard let previewLayer else { return }
        configurePreview(previewLayer, fillsDisplay: fillsDisplay)
    }
}

// MARK: - Mirroring

// snippet:begin ch13-mirroring
/// Mirrors the preview when the camera faces the person, whatever its
/// position says. The connection already mirrors front cameras, so
/// take over only when position and direction disagree, and do it
/// again after every switch: a new connection has no override.
@available(iOS 27.1, *)
@MainActor
func applyMirroring(
    to connection: AVCaptureConnection,
    for camera: AVCaptureDeviceDescriptor,
    in directions: AVCaptureDeviceDirectionMap
) {
    guard connection.isVideoMirroringSupported else { return }
    let id = camera.uniqueID
    let facesPerson = directions.forwardFacingDeviceDescriptors
        .contains { $0.uniqueID == id }
    let facesAway = directions.backwardFacingDeviceDescriptors
        .contains { $0.uniqueID == id }
    let isFrontCamera = camera.position == .front
    guard (facesPerson && !isFrontCamera) || (facesAway && isFrontCamera)
    else { return }

    // Setting isVideoMirrored while the connection adjusts mirroring
    // on its own raises an exception, so turn that off first.
    connection.automaticallyAdjustsVideoMirroring = false
    connection.isVideoMirrored = facesPerson
}
// snippet:end ch13-mirroring

// MARK: - Rotation

// snippet:begin ch13-rotation-coordinator
/// Keeps the preview level with the horizon. A rotation coordinator
/// stays bound to the camera it was made for, so the capture actor,
/// which owns this object, makes a new one after every switch from the
/// device it has just resolved and a layer already in a window. On
/// iPhone Duo its angle also changes when the app moves to the other
/// display. Angles reach the main actor through `rotate`.
@available(iOS 27.1, *)
final class PreviewRotation {
    private var coordinator: AVCaptureDevice.RotationCoordinator?
    private var observation: NSKeyValueObservation?

    func track(
        _ device: AVCaptureDevice,
        in layer: AVCaptureVideoPreviewLayer,
        rotate: @escaping @MainActor @Sendable (CGFloat) -> Void
    ) {
        let coordinator = AVCaptureDevice.RotationCoordinator(
            device: device, previewLayer: layer)
        self.coordinator = coordinator

        // Observation reports only later changes: apply this one now.
        let angle = coordinator.videoRotationAngleForHorizonLevelPreview
        Task { @MainActor in rotate(angle) }
        observation = coordinator.observe(
            \.videoRotationAngleForHorizonLevelPreview, options: .new
        ) { _, change in
            guard let angle = change.newValue else { return }
            // The coordinator reports changes on the main queue.
            MainActor.assumeIsolated { rotate(angle) }
        }
    }

    func stop() {
        observation = nil
        coordinator = nil
    }
}
// snippet:end ch13-rotation-coordinator

// MARK: - Preview aspect

// snippet:begin ch13-preview-aspect
/// Fills the display edge to edge, or keeps the whole frame visible when
/// the preview sits beside grouped controls.
@MainActor
func configurePreview(_ layer: AVCaptureVideoPreviewLayer,
                      fillsDisplay: Bool) {
    layer.videoGravity = fillsDisplay ? .resizeAspectFill : .resizeAspect
}

@available(iOS 27.1, *)
extension CaptureSession {
    /// Crops the square ultra wide sensor to a landscape shape for the
    /// inner display, when the active format supports it. Changing the
    /// ratio while recording ends the recording.
    func useLandscapeAspectRatio() throws {
        guard let device = videoInput?.device else { return }
        let ratio = AVCaptureDevice.AspectRatio.ratio16x9
        guard device.activeFormat.supportedDynamicAspectRatios
            .contains(ratio) else { return }
        try device.lockForConfiguration()
        defer { device.unlockForConfiguration() }
        device.setDynamicAspectRatio(ratio, completionHandler: nil)
    }
}
// snippet:end ch13-preview-aspect

// MARK: - Views

/// A view backed by a capture preview layer. It reports when it joins
/// or leaves a window, because the direction and rotation coordinators
/// need an on-screen view.
final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        // layerClass guarantees the type.
        layer as! AVCaptureVideoPreviewLayer
    }

    var onWindowChange: ((PreviewView) -> Void)?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        onWindowChange?(self)
    }
}

@available(iOS 27.1, *)
struct CameraPreview: UIViewRepresentable {
    let model: CameraModel

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.onWindowChange = { [model] view in
            if view.window != nil {
                model.attach(view)
            } else {
                model.detach()
            }
        }
        return view
    }

    func updateUIView(_ view: PreviewView, context: Context) {}
}

/// The camera screen: a preview that follows the camera facing the
/// person, with the controls from Chapter 13.
@available(iOS 27.1, *)
struct CameraScreen: View {
    @Environment(\.horizontalSizeClass) private var widthClass
    @State private var model = CameraModel()
    @State private var access = CameraAccess.unknown

    var body: some View {
        content
        #if !targetEnvironment(simulator)
            .task { access = await CameraAccess.request() }
        #endif
    }

    @ViewBuilder private var content: some View {
        #if targetEnvironment(simulator)
        CameraPlaceholder(reason: "The simulator has no camera.")
        #else
        switch access {
        case .unknown:
            ProgressView()
        case .denied:
            CameraPlaceholder(reason: "Camera access is off for DuoLab.")
        case .granted:
            CameraPreview(model: model)
                .ignoresSafeArea()
                .overlay {
                    if model.isSwitching {
                        Rectangle().fill(.black)
                    }
                }
                .overlay(alignment: .bottom) { controls }
        }
        #endif
    }

    private var controls: some View {
        VStack(spacing: 8) {
            Text(model.activeCamera?.localizedName ?? "No camera faces you")
                .font(.headline)
            if let failure = model.failure {
                Text(failure).font(.footnote)
            }
            Toggle("Fill the display", isOn: $model.fillsDisplay)
            if widthClass == .regular {
                Button("Landscape Aspect Ratio") {
                    Task { await model.useLandscapeAspectRatio() }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 20))
        .padding()
    }
}

enum CameraAccess {
    case unknown, granted, denied

    static func request() async -> CameraAccess {
        await AVCaptureDevice.requestAccess(for: .video) ? .granted : .denied
    }
}

struct CameraPlaceholder: View {
    let reason: LocalizedStringKey

    var body: some View {
        ContentUnavailableView {
            Label("No Camera", systemImage: "camera")
        } description: {
            Text(reason)
            Text("Run DuoLab on iPhone Duo to try this screen.")
        }
    }
}

#endif
