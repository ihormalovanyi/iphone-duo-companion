//
//  RootTabBarController.swift
//  DuoLabUIKit
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit

/// Two tabs: the chapter demos and a small settings screen. On iPhone
/// Duo the tab bar goes vertical on its own (Chapter 7); nothing here
/// opts in or out.
final class RootTabBarController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        tabs = [
            UITab(
                title: "Demos",
                image: UIImage(systemName: "list.bullet.rectangle"),
                identifier: "demos"
            ) { _ in
                UINavigationController(
                    rootViewController: DemoListViewController()
                )
            },
            UITab(
                title: "Settings",
                image: UIImage(systemName: "gearshape"),
                identifier: "settings"
            ) { _ in
                UINavigationController(
                    rootViewController: SettingsViewController()
                )
            },
        ]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}
