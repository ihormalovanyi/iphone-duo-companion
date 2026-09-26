//
//  Ch05SafeAreas.swift
//  DuoLabUIKit - Chapter 5
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit

/// A hero backdrop that extends under the bars, a card inside the
/// (asymmetric) layout margins with concentric corners, and a custom
/// bar placed with a bar layout region.
final class SafeAreasViewController: UIViewController {
    private let card = UIView()
    private let marginsLabel = ReadoutLabel()
    private let bottomBar = UIView()
    private let barLabel = ReadoutLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let hero = makeHero()
        view.addSubview(hero)
        NSLayoutConstraint.activate([
            hero.topAnchor.constraint(equalTo: view.topAnchor),
            hero.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hero.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hero.heightAnchor.constraint(
                equalTo: view.heightAnchor, multiplier: 0.35
            ),
        ])

        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)
        styleCard()
        pinCardToMargins()
        card.addSubview(marginsLabel)
        marginsLabel.pin(to: card.layoutMarginsGuide)

        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = .secondarySystemFill
        bottomBar.cornerConfiguration = .capsule()
        view.addSubview(bottomBar)
        bottomBar.addSubview(barLabel)
        barLabel.textAlignment = .center
        barLabel.pin(to: bottomBar.layoutMarginsGuide)
        NSLayoutConstraint.activate(barConstraints(for: bottomBar))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let frame = bottomBar.frame
        barLabel.text = """
            Bar \(frame.width.readout) x \(frame.height.readout) \
            at \(frame.minX.readout), \(frame.minY.readout)
            """
    }

    // snippet:begin ch05-layout-margins-asymmetric
    /// Pins the card to the layout margins. On iPhone Duo the leading
    /// and trailing margins can differ, so never copy one side's value
    /// to the other.
    private func pinCardToMargins() {
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        let margins = view.directionalLayoutMargins
        marginsLabel.text = """
            Leading margin: \(margins.leading.formatted()) pt
            Trailing margin: \(margins.trailing.formatted()) pt
            """
    }
    // snippet:end ch05-layout-margins-asymmetric

    // snippet:begin ch05-layout-region-bar
    /// Constraints for a custom 56 pt bar on the bottom edge. On iOS
    /// 27.1 the bar layout region supplies the guide; earlier systems
    /// fall back to the bottom of the safe area.
    private func barConstraints(for bar: UIView) -> [NSLayoutConstraint] {
        if #available(iOS 27.1, *) {
            let edge: NSDirectionalRectEdge = .bottom
            let guide = view.layoutGuide(for: .bar(onEdge: edge, extent: 56))
            return [
                bar.topAnchor.constraint(equalTo: guide.topAnchor),
                bar.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
                bar.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
                bar.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            ]
        }
        let safe = view.safeAreaLayoutGuide
        return [
            bar.heightAnchor.constraint(equalToConstant: 56),
            bar.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
            bar.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
        ]
    }
    // snippet:end ch05-layout-region-bar

    // snippet:begin ch05-corner-configuration
    /// Rounds the card concentrically with its container, down to a
    /// minimum of 12 pt, instead of hard-coding one radius for every
    /// display and window size.
    private func styleCard() {
        card.backgroundColor = .secondarySystemBackground
        card.cornerConfiguration = .corners(
            radius: .containerConcentric(minimum: 12)
        )
    }
    // snippet:end ch05-corner-configuration

    // snippet:begin ch05-background-extension-view
    /// A hero backdrop that reaches under a vertical bar. Pin the
    /// extension view to the view's edges, not to the safe area: it
    /// keeps its content view inside the safe area and fills the rest
    /// of its bounds with modifications of the content along the edges.
    private func makeHero() -> UIBackgroundExtensionView {
        let hero = UIBackgroundExtensionView()
        hero.contentView = GradientArtworkView() // your artwork
        hero.translatesAutoresizingMaskIntoConstraints = false
        return hero
    }
    // snippet:end ch05-background-extension-view
}
