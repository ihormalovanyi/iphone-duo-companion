//
//  SceneDelegate.swift
//  DuoLabUIKit
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit

/// One delegate for every scene of the app: each application window
/// gets its own tab bar controller (Chapter 12), and the camera capture
/// accessory's scene is recognized by its role (Chapter 14).
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        #if !targetEnvironment(macCatalyst)
        if connectCaptureAccessory(
            windowScene, session: session, options: connectionOptions
        ) {
            return
        }
        #endif
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = RootTabBarController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
