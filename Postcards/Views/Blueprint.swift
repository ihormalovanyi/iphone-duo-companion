//
//  Blueprint.swift
//  Postcards
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI

// MARK: - What the system reports

/// A reserved region as plain values, so reports compare and drive
/// `onChange`.
struct RegionRecord: Equatable {
    var frame: CGRect
    var isActive: Bool
    var margins: EdgeInsets

    @available(iOS 27.1, *)
    init(_ region: ReservedRegion) {
        frame = region.frame
        isActive = region.isActive
        margins = region.margins
    }
}

/// The full scene: its size and origin in window coordinates, and its
/// reserved regions.
struct SceneMeasure: Equatable {
    var size = CGSize.zero
    var origin = CGPoint.zero
    var divisions: [RegionRecord] = []
    var occlusions: [RegionRecord] = []
}

/// Everything the overlay draws, read from the APIs the book covers:
/// nothing is derived from the hinge angle or the device model.
@available(iOS 27.1, *)
struct SceneReport {
    var size: CGSize
    var insets: EdgeInsets
    var divisions: [RegionRecord]
    var occlusions: [RegionRecord]
    var widthClass: UserInterfaceSizeClass?
    var heightClass: UserInterfaceSizeClass?
    var barEdge: HorizontalEdge?
    var hinge: DeviceHinge?

    /// The safe area as a rectangle in the scene's coordinate space.
    var safeArea: CGRect {
        CGRect(x: insets.leading, y: insets.top,
               width: max(size.width - insets.leading - insets.trailing, 0),
               height: max(size.height - insets.top - insets.bottom, 0))
    }

    /// The strip a vertical bar occupies, if the system placed one.
    var barStrip: CGRect? {
        switch barEdge {
        case .leading: CGRect(x: 0, y: 0, width: insets.leading, height: size.height)
        case .trailing: CGRect(x: size.width - insets.trailing, y: 0, width: insets.trailing, height: size.height)
        default: nil
        }
    }
}

private enum Palette {
    static let amber = Color(red: 0.890, green: 0.604, blue: 0.176)
    static let pale = Color(red: 0.910, green: 0.925, blue: 0.949)
    static let ink = Color(red: 0.059, green: 0.071, blue: 0.090)
}

private func number(_ value: CGFloat) -> String {
    value.rounded() == value ? String(Int(value)) : String(format: "%.1f", value)
}

// MARK: - Reading the scene

/// Lays its content out inside the safe area and hands it a report of the
/// whole scene: a background that ignores the safe area measures the
/// scene and reads the reserved regions in the scene's coordinate space;
/// the insets are the difference between the two frames.
@available(iOS 27.1, *)
struct SceneReader<Content: View>: View {
    @ViewBuilder let content: (SceneReport) -> Content
    @Environment(\.horizontalSizeClass) private var widthClass
    @Environment(\.verticalSizeClass) private var heightClass
    @Environment(\.toolbarVerticalEdge) private var barEdge
    @State private var hinge: DeviceHinge?
    @State private var measure = SceneMeasure()

    var body: some View {
        GeometryReader { safe in
            let safeFrame = safe.frame(in: .global)
            let insets = EdgeInsets(
                top: max(safeFrame.minY - measure.origin.y, 0),
                leading: max(safeFrame.minX - measure.origin.x, 0),
                bottom: max(measure.origin.y + measure.size.height - safeFrame.maxY, 0),
                trailing: max(measure.origin.x + measure.size.width - safeFrame.maxX, 0))
            let report = SceneReport(
                size: measure.size == .zero ? safe.size : measure.size,
                insets: insets,
                divisions: measure.divisions,
                occlusions: measure.occlusions,
                widthClass: widthClass,
                heightClass: heightClass,
                barEdge: barEdge,
                hinge: hinge)
            content(report)
                .frame(width: safe.size.width, height: safe.size.height, alignment: .topLeading)
        }
        .background {
            GeometryReader { full in
                let current = SceneMeasure(
                    size: full.size,
                    origin: full.frame(in: .global).origin,
                    divisions: full.reservedRegions(kind: .division, options: .includeInactive).map(RegionRecord.init),
                    occlusions: full.reservedRegions(kind: .occlusion, options: .includeInactive).map(RegionRecord.init))
                Color.clear
                    .onChange(of: current, initial: true) { _, new in measure = new }
            }
            .ignoresSafeArea()
        }
        .onHingeChange { _, context in
            hinge = context.hinge
        }
    }
}

// MARK: - The overlay

/// Blueprint: the lines the system reports for the screen underneath,
/// drawn 1:1 over the dimmed app. The cards lay out around these lines;
/// the overlay makes them visible. Taps pass through it; the toggle in
/// the toolbar turns it off.
@available(iOS 27.1, *)
struct BlueprintOverlay: View {
    var body: some View {
        SceneReader { report in
            ZStack(alignment: .topLeading) {
                Palette.ink.opacity(0.66)
                    .ignoresSafeArea()
                SceneLines(report: report)
                    .offset(x: -report.insets.leading, y: -report.insets.top)
            }
        }
    }
}

/// The lines, in the scene's coordinate space, with horizontal labels.
@available(iOS 27.1, *)
struct SceneLines: View {
    let report: SceneReport

    private var regions: [(region: RegionRecord, text: String)] {
        report.divisions.map { region in
            (region, region.isActive ? "fold \(number(min(region.frame.width, region.frame.height))) pt" : "fold · inactive")
        } + report.occlusions.map { region in
            (region, region.isActive ? "occlusion \(number(region.frame.width)) × \(number(region.frame.height))" : "occlusion · inactive")
        }
    }

    var body: some View {
        let size = report.size
        ZStack(alignment: .topLeading) {
            grid(size: size)
            if let strip = report.barStrip {
                Rectangle()
                    .fill(Palette.amber.opacity(0.12))
                    .frame(width: strip.width, height: strip.height)
                    .offset(x: strip.minX, y: strip.minY)
                label("bar \(number(strip.width)) pt", color: Palette.amber)
                    .frame(width: size.width, alignment: report.barEdge == .leading ? .leading : .trailing)
                    .offset(y: size.height * 0.5)
            }
            let safe = report.safeArea
            Rectangle()
                .stroke(Palette.pale.opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                .frame(width: max(safe.width, 0), height: max(safe.height, 0))
                .offset(x: safe.minX, y: safe.minY)
            label("safe area", color: Palette.pale)
                .offset(x: safe.minX + 6, y: safe.maxY - 24)
            if report.insets.top > 0 {
                label("top \(number(report.insets.top))")
                    .offset(x: safe.minX + 6, y: max(report.insets.top - 22, 2))
            }
            if report.insets.bottom > 0 {
                label("bottom \(number(report.insets.bottom))")
                    .frame(width: size.width, alignment: .trailing)
                    .offset(x: -report.insets.trailing - 6, y: safe.maxY + 4)
            }
            // Shapes first, then every label, so no region covers a label.
            ForEach(Array(regions.enumerated()), id: \.offset) { _, item in
                regionShape(item.region)
            }
            ForEach(Array(regions.enumerated()), id: \.offset) { _, item in
                regionLabel(item.region, text: item.text)
            }
        }
        .frame(width: size.width, height: size.height, alignment: .topLeading)
        .clipped()
    }

    private func grid(size: CGSize) -> some View {
        Canvas { context, _ in
            var minor = Path()
            var major = Path()
            var x: CGFloat = 0
            var column = 0
            while x <= size.width {
                if column % 4 == 0 {
                    major.move(to: CGPoint(x: x, y: 0)); major.addLine(to: CGPoint(x: x, y: size.height))
                } else {
                    minor.move(to: CGPoint(x: x, y: 0)); minor.addLine(to: CGPoint(x: x, y: size.height))
                }
                x += 24; column += 1
            }
            var y: CGFloat = 0
            var row = 0
            while y <= size.height {
                if row % 4 == 0 {
                    major.move(to: CGPoint(x: 0, y: y)); major.addLine(to: CGPoint(x: size.width, y: y))
                } else {
                    minor.move(to: CGPoint(x: 0, y: y)); minor.addLine(to: CGPoint(x: size.width, y: y))
                }
                y += 24; row += 1
            }
            context.stroke(minor, with: .color(.white.opacity(0.05)), lineWidth: 0.5)
            context.stroke(major, with: .color(.white.opacity(0.11)), lineWidth: 0.7)
        }
    }

    private func regionShape(_ region: RegionRecord) -> some View {
        let frame = region.frame
        let core = frame.inset(by: UIEdgeInsets(top: region.margins.top, left: region.margins.leading,
                                                bottom: region.margins.bottom, right: region.margins.trailing))
        return ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Palette.amber.opacity(region.isActive ? 0.2 : 0.05))
                .frame(width: max(core.width, 0), height: max(core.height, 0))
                .offset(x: core.minX, y: core.minY)
            Rectangle()
                .strokeBorder(style: StrokeStyle(lineWidth: 1.2, dash: region.isActive ? [] : [3, 3]))
                .foregroundStyle(Palette.amber.opacity(region.isActive ? 1 : 0.55))
                .frame(width: max(frame.width, 0), height: max(frame.height, 0))
                .offset(x: frame.minX, y: frame.minY)
        }
    }

    /// The label hangs below the region, flush with its leading edge, or
    /// with its trailing edge when the region sits on the far side.
    private func regionLabel(_ region: RegionRecord, text: String) -> some View {
        let frame = region.frame
        let nearFarEdge = frame.midX > 0.55 * report.size.width
        // Right-aligned labels end inside the safe area, so a region in the
        // trailing strip never covers them.
        let rightEdge = min(frame.maxX, report.safeArea.maxX - 4)
        return label(text, color: Palette.amber)
            .frame(width: nearFarEdge ? max(rightEdge, 120) : 0, alignment: nearFarEdge ? .trailing : .leading)
            .offset(x: nearFarEdge ? 0 : frame.minX, y: frame.maxY + 4)
    }

    private func label(_ text: String, color: Color? = nil) -> some View {
        Text(text)
            .font(.system(size: 11.5, weight: .medium))
            .foregroundStyle(color ?? Palette.pale)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Palette.ink.opacity(0.88), in: .rect(cornerRadius: 4))
            .fixedSize()
    }
}
