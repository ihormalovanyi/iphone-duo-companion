//
//  Ch12Windows.swift
//  DuoLabUIKit - Chapter 12
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit

/// Two ways to open a second window: a menu with an activation action,
/// and a plain button that requests a scene and reports failures.
final class WindowsViewController: UIViewController {
    static let activityType = "pro.ihor.unfolded.DuoLabUIKit.window"

    private let readout = ReadoutLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Window",
            image: UIImage(systemName: "plus.rectangle.on.rectangle"),
            menu: UIMenu(children: [makeNewWindowAction()])
        )
        let stack = makeScrollingStack()
        stack.addArrangedSubview(makeButton("Request a new window") {
            [weak self] in self?.requestNewWindow()
        })
        stack.addArrangedSubview(readout)
        let multiple = UIApplication.shared.supportsMultipleScenes
        readout.text = "Supports multiple scenes: \(multiple ? "yes" : "no")"
    }

    // snippet:begin ch12-activation-action
    /// A "New Window" menu item. The system hides it where new windows
    /// can't be created, per Apple's iPhone Duo talk; the documentation
    /// offers the alternate action for iPhone.
    private func makeNewWindowAction() -> UIWindowScene.ActivationAction {
        let openHere = UIAction(title: "Open Here") { [weak self] _ in
            self?.showInPlace()
        }
        return UIWindowScene.ActivationAction(
            title: "New Window", alternate: openHere
        ) { _ in
            let activity = NSUserActivity(activityType: Self.activityType)
            return UIWindowScene.ActivationConfiguration(
                userActivity: activity
            )
        }
    }
    // snippet:end ch12-activation-action

    // snippet:begin ch12-request-scene-error
    /// Requests a new window from a button. New windows can't be
    /// created on the outer display, so the request can fail: say so
    /// instead of doing nothing.
    private func requestNewWindow() {
        let activity = NSUserActivity(activityType: Self.activityType)
        let request = UISceneSessionActivationRequest(
            userActivity: activity
        )
        UIApplication.shared.activateSceneSession(for: request) {
            [weak self] error in
            Task { @MainActor in
                self?.showActivationError(error)
            }
        }
    }
    // snippet:end ch12-request-scene-error

    private func showActivationError(_ error: any Error) {
        let alert = UIAlertController(
            title: "Couldn't Open a New Window",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showInPlace() {
        show(SceneGeometryViewController(), sender: self)
    }
}
