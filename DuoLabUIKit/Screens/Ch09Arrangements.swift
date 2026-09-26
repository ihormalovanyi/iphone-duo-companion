//
//  Ch09Arrangements.swift
//  DuoLabUIKit - Chapter 9
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit

/// A now-playing panel (primary) and a queue (secondary) in an
/// arrangement view controller, with a picker for the split, sized
/// split and overlay arrangements. The navigation controller stays
/// outside the arrangement.
@available(iOS 27.1, *)
final class ArrangementDemoViewController: UIViewController {
    private var arrangement: UIArrangementViewController?
    private let picker = UISegmentedControl(
        items: ["Split", "Sized split", "Overlay"]
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        embedArrangement()
        picker.selectedSegmentIndex = 0
        picker.addAction(
            UIAction { [weak self] _ in self?.applySelectedArrangement() },
            for: .valueChanged
        )
        navigationItem.titleView = picker
    }

    // snippet:begin ch09-uikit-arrangement
    /// Embeds an arrangement with the player as primary and the queue
    /// as secondary. The default arrangement is a split: side by side
    /// when the space is wider than tall, stacked when it is taller,
    /// adjusted for the fold.
    private func embedArrangement() {
        let arrangement = UIArrangementViewController()
        arrangement.setViewController(
            NowPlayingViewController(), for: .primary
        )
        arrangement.setViewController(
            QueueViewController(), for: .secondary
        )
        addChild(arrangement)
        view.addSubview(arrangement.view)
        arrangement.view.pin(to: view)
        arrangement.didMove(toParent: self)
        self.arrangement = arrangement
    }
    // snippet:end ch09-uikit-arrangement

    private func applySelectedArrangement() {
        switch picker.selectedSegmentIndex {
        case 1: applySizedSplit()
        case 2: applyOverlay()
        default: arrangement?.updateArrangement(.split, animated: true)
        }
    }

    // snippet:begin ch09-uikit-split-dimensions
    /// The player gets at least 280 pt and prefers 40% of the width,
    /// at most 60%, and a layout priority of 1. If the minimums cannot
    /// fit side by side, the split may show a single view.
    private func applySizedSplit() {
        var split = UISplitArrangement()
        var player = split.defaultViewProperties
        player.width.minimum = .absolute(280)
        player.width.preferred = .fractional(0.4)
        player.width.maximum = .fractional(0.6)
        player.layoutPriority = 1
        split.setViewProperties(player, for: .primary)
        arrangement?.updateArrangement(split, animated: true)
    }
    // snippet:end ch09-uikit-split-dimensions

    // snippet:begin ch09-uikit-overlay
    /// Layers the player over the queue while no division is active
    /// (closed or flat) and puts them side by side while the device is
    /// partially open. `edge` is the side the player takes in that
    /// side-by-side layout: here leading, not the default trailing.
    private func applyOverlay() {
        var overlay = UIOverlayArrangement()
        var player = overlay.defaultViewProperties
        player.edge = .leading
        overlay.setViewProperties(player, for: .primary)
        arrangement?.updateArrangement(overlay, animated: true)
    }
    // snippet:end ch09-uikit-overlay
}

/// The primary view: a large player that collapses to a mini player
/// while it is layered over the queue.
@available(iOS 27.1, *)
final class NowPlayingViewController: UIViewController {
    private let artwork = GradientArtworkView()
    private let status = ReadoutLabel()
    private var isCollapsed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        artwork.translatesAutoresizingMaskIntoConstraints = false
        artwork.cornerConfiguration = .corners(
            radius: .containerConcentric(minimum: 12)
        )
        artwork.clipsToBounds = true
        view.addSubview(artwork)
        view.addSubview(status)
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            artwork.topAnchor.constraint(equalTo: margins.topAnchor),
            artwork.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            artwork.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            artwork.heightAnchor.constraint(
                equalTo: artwork.widthAnchor, multiplier: 0.6
            ).prioritized(.defaultHigh),
            status.topAnchor.constraint(
                equalTo: artwork.bottomAnchor, constant: 8
            ),
            status.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            status.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            status.bottomAnchor.constraint(
                lessThanOrEqualTo: margins.bottomAnchor
            ),
        ])
    }

    // snippet:begin ch09-uikit-overlay-zindex
    /// In an overlay arrangement the player's z-index changes as the
    /// device folds and unfolds. Above zero, it sits on top of the
    /// queue, so it switches to its compact, collapsed form.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let state = arrangementViewController?.state(for: .primary)
        setCollapsed((state?.zIndex ?? 0) > 0)
    }
    // snippet:end ch09-uikit-overlay-zindex

    private func setCollapsed(_ collapsed: Bool) {
        let secondary = arrangementViewController?.state(for: .secondary)
        let text = """
            Player \(collapsed ? "collapsed" : "expanded")
            Queue hidden: \(secondary?.isHidden == true ? "yes" : "no")
            """
        if status.text != text { status.text = text }
        guard collapsed != isCollapsed else { return }
        isCollapsed = collapsed
        artwork.isHidden = collapsed
    }
}

/// The secondary view: a plain queue list.
final class QueueViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "track")
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int { 20 }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "track", for: indexPath
        )
        var content = cell.defaultContentConfiguration()
        content.text = "Track \(indexPath.row + 1)"
        content.secondaryText = "Up next"
        cell.contentConfiguration = content
        return cell
    }
}
