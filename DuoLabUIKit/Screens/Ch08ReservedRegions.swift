//
//  Ch08ReservedRegions.swift
//  DuoLabUIKit - Chapter 8
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit

/// Draws every reserved region over the screen (filled when active,
/// outlined when inactive) and keeps a custom bottom bar out of an
/// active division, the fold of a partially open device.
@available(iOS 27.1, *)
final class ReservedRegionsViewController: UIViewController {
    private let regionOverlay = RegionOverlayView()
    private let readout = ReadoutLabel()
    private let customBar = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let stack = makeScrollingStack()
        stack.addArrangedSubview(readout)
        customBar.backgroundColor = .secondarySystemBackground
        customBar.cornerConfiguration = .capsule()
        view.addSubview(customBar)
        view.addSubview(regionOverlay)
        regionOverlay.pin(to: view)
    }

    // snippet:begin ch08-uikit-query-regions
    /// Every reserved region that intersects this view: the fold
    /// (division) and the cameras (occlusion), active or not. Frames
    /// and margins are in this view's coordinate space.
    func currentRegions() -> [UIView.ReservedRegion] {
        let kinds: [UIView.ReservedRegion.Kind] = [.division, .occlusion]
        return kinds.flatMap { kind in
            view.reservedRegions(kind: kind, options: .includeInactive)
        }
    }
    // snippet:end ch08-uikit-query-regions

    // snippet:begin ch08-uikit-layout-timing
    /// Regions depend on the window and on this view's frame, so read
    /// them during layout, when both are current.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let regions = currentRegions()
        regionOverlay.regions = regions
        layoutCustomBar(avoiding: regions.filter {
            $0.kind == .division && $0.isActive
        })
        readout.text = describe(regions)
    }
    // snippet:end ch08-uikit-layout-timing

    /// Places the bar along the bottom of the safe area. When an active
    /// division crosses it, the bar moves as a whole to the trailing
    /// side of the fold instead of straddling it: the right side in a
    /// left-to-right layout, the left side in a right-to-left one.
    private func layoutCustomBar(avoiding folds: [UIView.ReservedRegion]) {
        let safe = view.bounds.inset(by: view.safeAreaInsets)
        var frame = CGRect(
            x: safe.minX + 16, y: safe.maxY - 72,
            width: safe.width - 32, height: 56
        )
        if let fold = folds.first(where: { $0.frame.intersects(frame) }) {
            let left = CGRect(
                x: safe.minX, y: frame.minY,
                width: fold.frame.minX - safe.minX, height: frame.height
            )
            let right = CGRect(
                x: fold.frame.maxX, y: frame.minY,
                width: safe.maxX - fold.frame.maxX, height: frame.height
            )
            let direction = view.effectiveUserInterfaceLayoutDirection
            let side = direction == .rightToLeft ? left : right
            frame = side.insetBy(dx: 16, dy: 0)
        }
        customBar.frame = frame
    }

    private func describe(_ regions: [UIView.ReservedRegion]) -> String {
        guard !regions.isEmpty else {
            return "No reserved regions intersect this view."
        }
        return regions.map { region in
            let kind = region.kind == .division ? "division" : "occlusion"
            let state = region.isActive ? "active" : "inactive"
            let f = region.frame
            return """
                \(kind), \(state): \(f.minX.readout), \(f.minY.readout), \
                \(f.width.readout) x \(f.height.readout)
                """
        }.joined(separator: "\n")
    }
}

/// Draws reserved regions: filled when active, dashed when inactive.
@available(iOS 27.1, *)
final class RegionOverlayView: UIView {
    var regions: [UIView.ReservedRegion] = [] {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        isUserInteractionEnabled = false
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func draw(_ rect: CGRect) {
        for region in regions {
            let color: UIColor = region.kind == .division
                ? .systemOrange : .systemPurple
            let path = UIBezierPath(rect: region.frame)
            if region.isActive {
                color.withAlphaComponent(0.35).setFill()
                path.fill()
            } else {
                path.setLineDash([6, 4], count: 2, phase: 0)
            }
            color.setStroke()
            path.lineWidth = 2
            path.stroke()
        }
    }
}
