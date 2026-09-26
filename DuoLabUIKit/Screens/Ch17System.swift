//
//  Ch17System.swift
//  DuoLabUIKit - Chapter 17
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit

/// Busy artwork under a custom floating bar. Turn on Reduce
/// Transparency in Settings > Accessibility and the bar switches from
/// a material to an opaque fill.
final class ReduceTransparencyViewController: UIViewController {
    private let readout = ReadoutLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        let artwork = GradientArtworkView(
            colors: [.systemYellow, .systemRed, .systemPurple]
        )
        view.addSubview(artwork)
        artwork.pin(to: view)

        let bar = BarBackgroundView()
        bar.cornerConfiguration = .capsule()
        bar.clipsToBounds = true
        view.addSubview(bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.contentView.addSubview(readout)
        readout.textAlignment = .center
        readout.pin(to: bar.contentView.layoutMarginsGuide)
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            bar.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16
            ),
            bar.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
        ])
        updateReadout()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateReadout),
            name: UIAccessibility.reduceTransparencyStatusDidChangeNotification,
            object: nil
        )
    }

    @objc private func updateReadout() {
        let isOn = UIAccessibility.isReduceTransparencyEnabled
        readout.text = "Reduce Transparency: \(isOn ? "on" : "off")"
    }
}

// snippet:begin ch17-uikit-reduce-transparency
/// A custom bar background: a material normally, an opaque fill when
/// Reduce Transparency is on, so the bar's content stays legible over
/// any artwork.
final class BarBackgroundView: UIVisualEffectView {
    private static let statusChange =
        UIAccessibility.reduceTransparencyStatusDidChangeNotification

    init() {
        super.init(effect: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(update),
            name: Self.statusChange, object: nil
        )
        update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    @objc private func update() {
        let isOpaque = UIAccessibility.isReduceTransparencyEnabled
        effect = isOpaque ? nil : UIBlurEffect(style: .systemMaterial)
        backgroundColor = isOpaque ? .secondarySystemBackground : nil
    }
}
// snippet:end ch17-uikit-reduce-transparency
