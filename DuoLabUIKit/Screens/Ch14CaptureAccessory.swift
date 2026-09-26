//
//  Ch14CaptureAccessory.swift
//  DuoLabUIKit - Chapter 14
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  The camera capture accessory needs a device: the simulator has no
//  camera, so the accessory is never presented there. The registration,
//  the enable switch and the role check still run and can be read.
//

import Observation
import UIKit

/// The state the camera screen and its accessory share. The app owns
/// it; the accessory scene receives the same object as userInfo.
@MainActor @Observable
final class CaptureModel {
    var isRecording = false
    var takeCount = 0
}

/// Stands in for the app's camera screen: the accessory is registered
/// here, on the view controller that shows the capture interface.
final class CaptureViewController: UIViewController {
    let model = CaptureModel()
    private let availability = ReadoutLabel()
    private let enabledSwitch = UISwitch()
    private let enabledRow = UIStackView()
    #if !targetEnvironment(macCatalyst)
    private var registration: UISceneAccessoryRegistration?
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        let preview = GradientArtworkView(colors: [.darkGray, .black])
        view.addSubview(preview)
        preview.pin(to: view)

        let stack = makeScrollingStack()
        let label = UILabel()
        label.text = "Show controls on the outer display"
        label.textColor = .white
        label.numberOfLines = 0
        enabledSwitch.isOn = true
        enabledSwitch.addAction(
            UIAction { [weak self] _ in self?.updateEnabled() },
            for: .valueChanged
        )
        enabledRow.addArrangedSubview(label)
        enabledRow.addArrangedSubview(enabledSwitch)
        enabledRow.spacing = 8
        stack.addArrangedSubview(enabledRow)
        availability.textColor = .white
        stack.addArrangedSubview(availability)
        stack.addArrangedSubview(makeButton("Record") { [weak self] in
            guard let model = self?.model else { return }
            model.isRecording.toggle()
            if model.isRecording { model.takeCount += 1 }
        })
        #if !targetEnvironment(macCatalyst)
        registerCaptureAccessory()
        #endif
    }

    #if !targetEnvironment(macCatalyst)
    // snippet:begin ch14-uikit-register-accessory
    /// Registers the capture accessory on the camera screen itself, so
    /// the system presents it only while this screen is onscreen. The
    /// shared model travels as userInfo; this controller keeps its own
    /// strong reference to it.
    private func registerCaptureAccessory() {
        guard #available(iOS 27.1, *) else { return }
        let configuration = UISceneConfiguration()
        configuration.delegateClass = SceneDelegate.self
        let accessory = UISceneAccessory.cameraCapture(
            sceneConfiguration: configuration, userInfo: model
        )
        registration = registerSceneAccessory(accessory)
    }

    /// The switch turns the accessory's content on and off; whether the
    /// system can show it at all is `isAvailable`, so the switch shows
    /// only while the accessory is available.
    private func updateEnabled() {
        registration?.isEnabled = enabledSwitch.isOn
    }

    override func updateProperties() {
        super.updateProperties()
        let available = registration?.isAvailable == true
        enabledRow.isHidden = !available
        availability.text = available
            ? "Accessory available"
            : "Accessory not available"
    }
    // snippet:end ch14-uikit-register-accessory
    #else
    private func updateEnabled() {}
    #endif
}

#if !targetEnvironment(macCatalyst)
// snippet:begin ch14-uikit-accessory-role
extension SceneDelegate {
    /// Sets up the accessory's scene when this is one. Nothing in the
    /// scene manifest describes it: the system assigns the role, and
    /// the shared model arrives as the accessory's userInfo.
    func connectCaptureAccessory(
        _ scene: UIWindowScene,
        session: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> Bool {
        guard #available(iOS 27.1, *),
              session.role == .windowCameraCaptureAccessory,
              let model = options.sceneAccessoryUserInfo as? CaptureModel
        else { return false }
        let window = UIWindow(windowScene: scene)
        window.rootViewController = CaptureControlsViewController(
            model: model
        )
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
// snippet:end ch14-uikit-accessory-role
#endif

/// The accessory's content: a status and take readout driven by the
/// shared model, with no controls; recording stays on the camera
/// screen. `updateProperties()` tracks the model's changes.
final class CaptureControlsViewController: UIViewController {
    private let model: CaptureModel
    private let status = ReadoutLabel()
    private let takes = ReadoutLabel()

    init(model: CaptureModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        status.textColor = .white
        status.textAlignment = .center
        status.font = .preferredFont(forTextStyle: .title2)
        takes.textColor = .white
        takes.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [status, takes])
        stack.axis = .vertical
        stack.spacing = 12
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func updateProperties() {
        super.updateProperties()
        status.text = model.isRecording ? "Recording" : "Ready"
        takes.text = model.takeCount == 1
            ? "1 take"
            : "\(model.takeCount) takes"
    }
}
