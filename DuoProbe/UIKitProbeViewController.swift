//
//  UIKitProbeViewController.swift
//  DuoProbe
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI
import UIKit

/// Hosts the UIKit probe in the SwiftUI tab view.
struct UIKitProbeView: UIViewControllerRepresentable {
    @Environment(ProbeLog.self) private var log

    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(
            rootViewController: UIKitProbeViewController(log: log)
        )
    }

    func updateUIViewController(
        _ controller: UINavigationController,
        context: Context
    ) {}
}

/// The UIKit probe. It records a layout event from every
/// `viewDidLayoutSubviews()` (throttled by the log), a hinge event from a
/// `UIHingeInteraction`, a scene event for every activation-state
/// notification of its scene, and a keyboard event for every keyboard
/// notification. Size-class and vertical-bar-edge trait changes ask for
/// a new layout pass, which records them.
final class UIKitProbeViewController: UIViewController {
    private let log: ProbeLog
    private var hinge: HingeValues?
    private let textField = UITextField()
    private let readout = UITextView()

    init(log: ProbeLog) {
        self.log = log
        super.init(nibName: nil, bundle: nil)
        title = "UIKit probe"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Record now",
            image: UIImage(systemName: "record.circle"),
            primaryAction: UIAction { [weak self] _ in
                self?.record(.manual)
            }
        )
        buildViews()
        observeTraits()
        observeHinge()
        observeNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if LaunchOptions.focusesKeyboard {
            textField.becomeFirstResponder()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        record(.layout)
    }

    override func updateProperties() {
        super.updateProperties()
        // Observation tracking: runs again whenever the log changes.
        readout.text = "Pose: \(log.pose.title)\n\n\(log.lastRecordText)"
    }

    // MARK: Observation

    private func observeTraits() {
        var traits: [UITrait] = [
            UITraitHorizontalSizeClass.self,
            UITraitVerticalSizeClass.self,
        ]
        if #available(iOS 27.1, *) {
            traits += UITraitCollection.systemTraitsAffectingVerticalBarEdge
        }
        registerForTraitChanges(traits) { (self: Self, _: UITraitCollection) in
            self.view.setNeedsLayout()
        }
    }

    private func observeHinge() {
        guard #available(iOS 27.1, *) else { return }
        let interaction = UIHingeInteraction { [weak self] _, update in
            self?.hinge = HingeValues(update.hinge)
            self?.record(.hinge)
        }
        view.addInteraction(interaction)
    }

    private func observeNotifications() {
        let center = NotificationCenter.default
        let sceneNotifications: [Notification.Name] = [
            UIScene.willConnectNotification,
            UIScene.didActivateNotification,
            UIScene.willDeactivateNotification,
            UIScene.didEnterBackgroundNotification,
            UIScene.willEnterForegroundNotification,
        ]
        for name in sceneNotifications {
            center.addObserver(
                self, selector: #selector(sceneChanged(_:)),
                name: name, object: nil
            )
        }
        for name in KeyboardNotifications.names {
            center.addObserver(
                self, selector: #selector(keyboardChanged(_:)),
                name: name, object: nil
            )
        }
    }

    @objc private func sceneChanged(_ notification: Notification) {
        guard let scene = notification.object as? UIWindowScene,
              scene === view.window?.windowScene
        else { return }
        record(.scene)
    }

    @objc private func keyboardChanged(_ notification: Notification) {
        guard view.window != nil else { return }
        record(
            .keyboard,
            keyboardFrame: KeyboardNotifications.endFrame(notification)
        )
    }

    // MARK: Recording

    private func record(
        _ event: ProbeRecord.Event,
        keyboardFrame: CGRect? = nil
    ) {
        // A layout pass outside a window has nothing to measure.
        if event == .layout, view.window == nil { return }
        let traits = traitCollection
        let direction = view.effectiveUserInterfaceLayoutDirection
        var record = ProbeRecord(pose: log.pose, source: .uikit, event: event)
        record.fillScene(view.window?.windowScene)
        record.fillHinge(hinge)
        record.sceneSize = view.window.map { .init($0.bounds.size) }
        record.displayScale = Double(traits.displayScale)
        record.hSizeClass = traits.horizontalSizeClass.probeName
        record.vSizeClass = traits.verticalSizeClass.probeName
        record.userInterfaceIdiom = traits.userInterfaceIdiom.probeName
        record.safeAreaInsets = .init(
            view.safeAreaInsets, layoutDirection: direction
        )
        record.layoutMargins = .init(view.directionalLayoutMargins)
        record.keyboardFrame = keyboardFrame.map { ProbeRecord.Rect($0) }
        record.layoutDirection = direction.probeName
        record.reduceTransparency = UIAccessibility.isReduceTransparencyEnabled
        if #available(iOS 27.1, *) {
            record.verticalBarEdge = traits.verticalBarEdge.probeName
            fillRegions(&record, layoutDirection: direction)
        }
        log.record(record)
    }

    @available(iOS 27.1, *)
    private func fillRegions(
        _ record: inout ProbeRecord,
        layoutDirection: UIUserInterfaceLayoutDirection
    ) {
        func regions(
            _ kind: UIView.ReservedRegion.Kind,
            _ options: UIView.ReservedRegion.QueryOptions
        ) -> [ProbeRecord.Region] {
            view.reservedRegions(kind: kind, options: options).map {
                ProbeRecord.Region($0, layoutDirection: layoutDirection)
            }
        }
        record.regionsDivisionActive = regions(.division, [])
        record.regionsDivisionAll = regions(.division, .includeInactive)
        record.regionsOcclusionActive = regions(.occlusion, [])
        record.regionsOcclusionAll = regions(.occlusion, .includeInactive)
    }

    // MARK: Views

    private func buildViews() {
        textField.placeholder = "Type here to show the keyboard"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        readout.isEditable = false
        readout.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        readout.backgroundColor = .secondarySystemGroupedBackground
        readout.layer.cornerRadius = 12
        readout.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        view.addSubview(readout)
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: margins.topAnchor),
            textField.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            textField.trailingAnchor.constraint(
                equalTo: margins.trailingAnchor
            ),
            readout.topAnchor.constraint(
                equalTo: textField.bottomAnchor, constant: 12
            ),
            readout.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            readout.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            readout.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
        ])
    }
}
