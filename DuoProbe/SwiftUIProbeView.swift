//
//  SwiftUIProbeView.swift
//  DuoProbe
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import Combine
import SwiftUI
import UIKit

/// The SwiftUI probe and the app's controls: pose picker, "Record now",
/// "Share log", a text field for keyboard records, and the last record.
///
/// It records a layout event whenever `onGeometryChange` reports a new
/// size, safe area, margin or region set; a hinge event from
/// `onHingeChange`; a scene event when `scenePhase` changes; and a
/// keyboard event for every keyboard notification.
struct SwiftUIProbeView: View {
    /// Layout and keyboard events are recorded only while this tab is
    /// selected, so the log doesn't mix in an offscreen copy.
    let isActive: Bool

    @Environment(ProbeLog.self) private var log
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.verticalSizeClass) private var vSizeClass
    @Environment(\.displayScale) private var displayScale
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityReduceTransparency)
    private var reduceTransparency
    @Environment(\.scenePhase) private var scenePhase

    @State private var geometry: ProbeGeometry?
    @State private var safeArea: EdgeInsets?
    @State private var hinge: HingeValues?
    @State private var toolbarEdge: String?
    @State private var windowScene: UIWindowScene?
    @State private var text = ""
    @FocusState private var isTextFieldFocused: Bool

    @MainActor private static let keyboard = Publishers.MergeMany(
        KeyboardNotifications.names.map {
            NotificationCenter.default.publisher(for: $0)
        }
    )

    var body: some View {
        @Bindable var log = log
        NavigationStack {
            Form {
                Section("Pose") {
                    Picker("Pose", selection: $log.pose) {
                        ForEach(PoseLabel.allCases) { pose in
                            Text(pose.title).tag(pose)
                        }
                    }
                }
                Section {
                    Button("Record now") { record(.manual) }
                    ShareLink("Share log", item: log.fileURL)
                    LabeledContent("Lines this session") {
                        Text(log.count, format: .number)
                    }
                }
                Section("Keyboard") {
                    TextField("Type here to show the keyboard", text: $text)
                        .focused($isTextFieldFocused)
                }
                Section("Last record") {
                    Text(log.lastRecordText)
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                }
            }
            .navigationTitle("DuoProbe")
            .background {
                ToolbarVerticalEdgeObserver { toolbarEdge = $0 }
            }
        }
        .background {
            // Inside the safe area: the proxy reports the insets around it.
            GeometryReader { _ in
                Color.clear.onGeometryChange(for: EdgeInsets.self) {
                    $0.safeAreaInsets
                } action: { newValue in
                    safeArea = newValue
                    if isActive { record(.layout) }
                }
            }
        }
        .background {
            // Full bleed: the scene's size, and regions in the same
            // coordinate space as the UIKit probe's.
            GeometryReader { _ in
                Color.clear.onGeometryChange(for: ProbeGeometry.self) {
                    ProbeGeometry($0)
                } action: { newValue in
                    geometry = newValue
                    if isActive { record(.layout) }
                }
            }
            .ignoresSafeArea()
        }
        .background(WindowSceneReader { windowScene = $0 })
        .modifier(HingeChangeObserver { values in
            hinge = values
            record(.hinge)
        })
        .onChange(of: scenePhase) {
            record(.scene)
        }
        .task {
            if isActive, LaunchOptions.focusesKeyboard {
                isTextFieldFocused = true
            }
        }
        .onReceive(Self.keyboard) { notification in
            guard isActive else { return }
            record(
                .keyboard,
                keyboardFrame: KeyboardNotifications.endFrame(notification)
            )
        }
    }

    private func record(
        _ event: ProbeRecord.Event,
        keyboardFrame: CGRect? = nil
    ) {
        var record = ProbeRecord(pose: log.pose, source: .swiftui, event: event)
        record.fillScene(windowScene)
        record.fillHinge(hinge)
        if let geometry {
            record.sceneSize = .init(geometry.size)
            record.layoutMargins = geometry.contentMargins.map {
                ProbeRecord.Insets($0)
            }
            record.regionsDivisionActive = geometry.divisionActive?.records
            record.regionsDivisionAll = geometry.divisionAll?.records
            record.regionsOcclusionActive = geometry.occlusionActive?.records
            record.regionsOcclusionAll = geometry.occlusionAll?.records
        }
        record.safeAreaInsets = safeArea.map { ProbeRecord.Insets($0) }
        record.displayScale = Double(displayScale)
        record.hSizeClass = hSizeClass?.probeName
        record.vSizeClass = vSizeClass?.probeName
        record.toolbarVerticalEdge = toolbarEdge
        record.scenePhase = scenePhase.probeName
        record.keyboardFrame = keyboardFrame.map { ProbeRecord.Rect($0) }
        record.layoutDirection = layoutDirection.probeName
        record.reduceTransparency = reduceTransparency
        log.record(record)
    }
}

/// What the SwiftUI probe reads from a full-bleed geometry proxy. The
/// region arrays stay `nil` before iOS 27.1.
struct ProbeGeometry: Equatable, Sendable {
    var size: CGSize
    var contentMargins: EdgeInsets?
    var divisionActive: [RegionValues]?
    var divisionAll: [RegionValues]?
    var occlusionActive: [RegionValues]?
    var occlusionAll: [RegionValues]?

    /// A reserved region in the proxy's coordinate space.
    struct RegionValues: Equatable, Sendable {
        var frame: CGRect
        var margins: EdgeInsets
        var isActive: Bool
    }

    init(_ proxy: GeometryProxy) {
        size = proxy.size
        guard #available(iOS 27.1, *) else { return }
        contentMargins = proxy.contentMargins(for: .container)
        func regions(
            _ kind: ReservedRegion.Kind,
            _ options: ReservedRegion.QueryOptions
        ) -> [RegionValues] {
            proxy.reservedRegions(
                kind: kind, options: options, layoutDirectionBehavior: .mirrors
            ).map { region in
                RegionValues(
                    frame: region.frame,
                    margins: region.margins,
                    isActive: region.isActive
                )
            }
        }
        divisionActive = regions(.division, [])
        divisionAll = regions(.division, .includeInactive)
        occlusionActive = regions(.occlusion, [])
        occlusionAll = regions(.occlusion, .includeInactive)
    }
}

extension [ProbeGeometry.RegionValues] {
    var records: [ProbeRecord.Region] {
        map { region in
            ProbeRecord.Region(
                frame: .init(region.frame),
                margins: .init(region.margins),
                isActive: region.isActive
            )
        }
    }
}

/// Reports `onHingeChange` values on iOS 27.1 and does nothing before.
private struct HingeChangeObserver: ViewModifier {
    let action: (HingeValues) -> Void

    func body(content: Content) -> some View {
        if #available(iOS 27.1, *) {
            content.onHingeChange { _, newContext in
                action(HingeValues(newContext.hinge))
            }
        } else {
            content
        }
    }
}

/// Reports the `toolbarVerticalEdge` environment value on iOS 27.1.
private struct ToolbarVerticalEdgeObserver: View {
    let action: (String?) -> Void

    var body: some View {
        if #available(iOS 27.1, *) {
            EdgeReader(action: action)
        }
    }

    @available(iOS 27.1, *)
    private struct EdgeReader: View {
        @Environment(\.toolbarVerticalEdge) private var edge
        let action: (String?) -> Void

        var body: some View {
            Color.clear.onChange(of: edge, initial: true) {
                action(edge?.probeName)
            }
        }
    }
}

/// Hands the hosting window scene to SwiftUI, so the probe can read the
/// scene's screen, geometry and activation state.
private struct WindowSceneReader: UIViewRepresentable {
    let action: (UIWindowScene?) -> Void

    func makeUIView(context: Context) -> SceneAnchorView {
        let view = SceneAnchorView()
        view.action = action
        return view
    }

    func updateUIView(_ view: SceneAnchorView, context: Context) {
        view.action = action
    }

    final class SceneAnchorView: UIView {
        var action: ((UIWindowScene?) -> Void)?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            action?(window?.windowScene)
        }
    }
}
