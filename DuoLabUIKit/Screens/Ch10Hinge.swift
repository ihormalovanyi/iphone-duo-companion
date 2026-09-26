//
//  Ch10Hinge.swift
//  DuoLabUIKit - Chapter 10
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit

/// Reads the hinge with a hinge interaction and tilts a card while the
/// device is partially open. Layout never depends on the angle; for
/// layout, use arrangements and reserved regions (Chapters 8 and 9).
@available(iOS 27.1, *)
final class HingeViewController: UIViewController {
    private let card = GradientArtworkView()
    private let readout = ReadoutLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        card.translatesAutoresizingMaskIntoConstraints = false
        card.cornerConfiguration = .corners(radius: .fixed(20))
        view.addSubview(card)
        view.addSubview(readout)
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 200),
            card.heightAnchor.constraint(equalToConstant: 260),
            readout.topAnchor.constraint(equalTo: margins.topAnchor),
            readout.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            readout.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
        ])
        readout.text = "Waiting for a hinge update"
        addHingeInteraction()
    }

    // snippet:begin ch10-uikit-hinge-interaction
    /// Tilts the card while the device is partially open and resets it
    /// otherwise. UIKit reports the angle in radians. A nil hinge means
    /// no hinge data for this view: handle it like "not partially open".
    private func addHingeInteraction() {
        let interaction = UIHingeInteraction { [weak self] _, update in
            guard let self else { return }
            let degrees = update.hinge.map { $0.angle * 180 / .pi }
            showReadout(for: update.hinge, degrees: degrees)
            if update.hinge?.status == .partiallyOpen, let degrees {
                tiltCard(byDegrees: degrees)
            } else {
                resetCard()
            }
        }
        view.addInteraction(interaction)
    }
    // snippet:end ch10-uikit-hinge-interaction

    /// A gentle 3D tilt: flat at 180 degrees, 20 degrees of tilt at 90.
    private func tiltCard(byDegrees angle: CGFloat) {
        let tilt = (180 - min(max(angle, 0), 180)) / 90 * 20
        var transform = CATransform3DIdentity
        transform.m34 = -1 / 600
        transform = CATransform3DRotate(
            transform, tilt * .pi / 180, 1, 0, 0
        )
        card.layer.transform = transform
    }

    private func resetCard() {
        card.layer.transform = CATransform3DIdentity
    }

    /// Shows the status and the angle, with the degrees the interaction
    /// already converted, so the radians are converted once.
    private func showReadout(for hinge: UIHinge?, degrees: CGFloat?) {
        guard let hinge, let degrees else {
            readout.text = "Hinge: nil"
            return
        }
        let status = switch hinge.status {
        case .closed: "closed"
        case .partiallyOpen: "partially open"
        case .fullyOpen: "fully open"
        case .unknown: "unknown"
        @unknown default: "unknown"
        }
        readout.text = """
            Status: \(status)
            Angle: \(hinge.angle.formatted()) rad \
            (\(degrees.readout) degrees)
            """
    }
}
