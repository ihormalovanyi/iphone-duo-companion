//
//  SettingsViewController.swift
//  DuoLabUIKit
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit

/// Build facts and a layout-direction switch for checking every demo in
/// right-to-left. Vertical bars keep their physical side in RTL while
/// content mirrors around them (Chapter 5).
final class SettingsViewController: UIViewController {
    private let facts = ReadoutLabel()
    private let rtlSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemGroupedBackground
        let stack = makeScrollingStack()

        let rtlLabel = UILabel()
        rtlLabel.text = "Right-to-left layout"
        rtlLabel.font = .preferredFont(forTextStyle: .body)
        rtlLabel.adjustsFontForContentSizeCategory = true
        rtlSwitch.addAction(
            UIAction { [weak self] _ in self?.applyLayoutDirection() },
            for: .valueChanged
        )
        let row = UIStackView(arrangedSubviews: [rtlLabel, rtlSwitch])
        row.spacing = 8
        stack.addArrangedSubview(row)
        stack.addArrangedSubview(facts)

        let info = Bundle.main.infoDictionary ?? [:]
        let sdk = info["DTSDKBuild"] as? String ?? "unknown"
        let os = ProcessInfo.processInfo.operatingSystemVersionString
        facts.text = """
            SDK build: \(sdk)
            Running: \(os)
            """
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let root = view.window?.rootViewController
        rtlSwitch.isOn = root?.traitOverrides.layoutDirection == .rightToLeft
    }

    /// Overrides the layout-direction trait for the whole window.
    private func applyLayoutDirection() {
        guard let root = view.window?.rootViewController else { return }
        root.traitOverrides.layoutDirection =
            rtlSwitch.isOn ? .rightToLeft : .leftToRight
    }
}
