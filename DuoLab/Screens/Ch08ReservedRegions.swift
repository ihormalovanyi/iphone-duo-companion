//
//  Ch08ReservedRegions.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 8: the fold and the cameras as reserved regions.
//

import SwiftUI

// iOS 27.1 symbols don't compile for Mac Catalyst in Xcode 27.1 beta
// (185924957); see Chapter 19.
#if !targetEnvironment(macCatalyst)

// MARK: - Query

// snippet:begin ch08-query-regions
/// Lists every reserved region: the fold is a division; cameras and the
/// Dynamic Island are occlusions. `.includeInactive` also returns
/// regions that don't affect layout right now, like the fold while the
/// device is flat. Each frame includes the region's margins.
@available(iOS 27.1, *)
struct ReservedRegionList: View {
    @State private var regions: [ReservedRegion] = []

    var body: some View {
        List(regions) { region in
            VStack(alignment: .leading, spacing: 4) {
                Text(region.kind == .division ? "Division" : "Occlusion")
                    .font(.headline)
                Text(region.isActive ? "Active" : "Inactive")
                Text("Frame " + DuoFormat.rect(region.frame))
            }
        }
        .background {
            // Query during layout, from a reader that spans the scene:
            // a query returns only the regions that intersect the view.
            GeometryReader { proxy in
                let found = proxy.reservedRegions(
                    kind: .division, options: .includeInactive)
                    + proxy.reservedRegions(
                        kind: .occlusion, options: .includeInactive)
                Color.clear
                    .onChange(of: found, initial: true) { regions = found }
            }
            .ignoresSafeArea()
        }
    }
}
// snippet:end ch08-query-regions

@available(iOS 27.1, *)
struct QueryRegionsScreen: View {
    var body: some View {
        ReservedRegionList()
            .safeAreaInset(edge: .bottom) {
                DemoHint("""
                    The frame includes the margins. Fold the device \
                    partway to make the division active.
                    """)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.bar)
            }
    }
}

// MARK: - Draw

// snippet:begin ch08-draw-regions
/// Draws every reserved region over the content. The outline is the
/// frame, which includes the margins; the filled core is the frame
/// minus its margins. Solid outlines are active, dashed are inactive.
@available(iOS 27.1, *)
struct ReservedRegionOverlay: View {
    var body: some View {
        GeometryReader { proxy in
            let regions =
                proxy.reservedRegions(kind: .division,
                                      options: .includeInactive)
                + proxy.reservedRegions(kind: .occlusion,
                                        options: .includeInactive)
            ForEach(regions) { region in
                marker(for: region)
                    .frame(width: region.frame.width,
                           height: region.frame.height)
                    .position(x: region.frame.midX, y: region.frame.midY)
            }
        }
        .allowsHitTesting(false)
    }

    private func marker(for region: ReservedRegion) -> some View {
        let color: Color = region.kind == .division ? .orange : .pink
        let dash: [CGFloat] = region.isActive ? [] : [6, 4]
        return Rectangle()
            .strokeBorder(color, style: StrokeStyle(lineWidth: 2,
                                                    dash: dash))
            .background {
                // The core: the frame minus its margins.
                Rectangle()
                    .fill(color.opacity(region.isActive ? 0.5 : 0.2))
                    .padding(region.margins)
            }
    }
}
// snippet:end ch08-draw-regions

@available(iOS 27.1, *)
struct DrawRegionsScreen: View {
    var body: some View {
        List(1...30, id: \.self) { row in
            Text("Row \(row)")
        }
        .overlay {
            // Ignore the safe area so regions at the display edge, like
            // the outer camera, fall inside the overlay's bounds.
            ReservedRegionOverlay()
                .ignoresSafeArea()
        }
    }
}

// MARK: - Displace a custom bar

// snippet:begin ch08-displace-custom-bar
/// A custom bottom bar that moves to the trailing side of the fold
/// while the device is folded like a book, instead of straddling the
/// fold. Folded like a laptop, the fold is horizontal, the bar is
/// already below it, and it stays put.
@available(iOS 27.1, *)
struct FoldAwareBottomBar<Bar: View>: View {
    @ViewBuilder let bar: Bar

    var body: some View {
        GeometryReader { proxy in
            let fold = proxy.reservedRegions(kind: .division)
                .first { $0.isActive && $0.frame.height > $0.frame.width }
            bar
                .frame(maxWidth: .infinity)
                .padding(.leading, fold?.frame.maxX ?? 0)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .animation(.smooth, value: fold?.frame)
        }
    }
}
// snippet:end ch08-displace-custom-bar

@available(iOS 27.1, *)
struct CustomBarScreen: View {
    var body: some View {
        ZStack {
            HeroArtwork()
                .ignoresSafeArea()
            FoldAwareBottomBar {
                HStack(spacing: 24) {
                    Button("Rewind", systemImage: "gobackward.15") {}
                    Button("Play", systemImage: "play.fill") {}
                    Button("Forward", systemImage: "goforward.15") {}
                }
                .labelStyle(.iconOnly)
                .font(.title2)
                .padding()
                .background(.regularMaterial, in: .capsule)
                .padding()
            }
        }
    }
}

// MARK: - Even columns

// snippet:begin ch08-even-columns
/// Picks a column count from the width, then rounds it down to an even
/// number whenever the display has a fold, active or not, so a column
/// never straddles the fold. Inactive regions exist for structural
/// decisions like this one.
@available(iOS 27.1, *)
struct FoldAwareGrid: View {
    let items: [String]

    var body: some View {
        GeometryReader { proxy in
            let hasFold = !proxy.reservedRegions(
                kind: .division, options: .includeInactive
            ).isEmpty
            let fitting = max(1, Int(proxy.size.width / 140))
            let count = hasFold ? max(2, fitting / 2 * 2) : fitting

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(),
                                         count: count)) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .background(.tint.opacity(0.15),
                                        in: .rect(cornerRadius: 12))
                    }
                }
                .padding()
            }
        }
    }
}
// snippet:end ch08-even-columns

@available(iOS 27.1, *)
struct EvenColumnsScreen: View {
    var body: some View {
        FoldAwareGrid(items: (1...40).map { "Item \($0)" })
    }
}

// MARK: - Layout direction behavior

// snippet:begin ch08-layout-direction-behavior
/// Reads the same regions both ways. `.mirrors`, the default, flips the
/// frames in a right-to-left layout so they line up with views SwiftUI
/// places; `.fixed` keeps the physical frames, for drawing that isn't
/// mirrored. The cameras themselves never move.
@available(iOS 27.1, *)
struct RegionDirectionReadout: View {
    @State private var mirrored: [ReservedRegion] = []
    @State private var fixed: [ReservedRegion] = []

    var body: some View {
        List {
            Section(".mirrors (the default)") { frames(of: mirrored) }
            Section(".fixed") { frames(of: fixed) }
        }
        .background {
            GeometryReader { proxy in
                let flipped = proxy.reservedRegions(
                    kind: .occlusion, options: .includeInactive)
                let physical = proxy.reservedRegions(
                    kind: .occlusion, options: .includeInactive,
                    layoutDirectionBehavior: .fixed)
                Color.clear
                    .onChange(of: flipped + physical, initial: true) {
                        mirrored = flipped
                        fixed = physical
                    }
            }
            .ignoresSafeArea()
        }
    }

    private func frames(of regions: [ReservedRegion]) -> some View {
        ForEach(regions) { region in
            Text(DuoFormat.rect(region.frame))
                .monospacedDigit()
        }
    }
}
// snippet:end ch08-layout-direction-behavior

@available(iOS 27.1, *)
struct LayoutDirectionScreen: View {
    @State private var isRightToLeft = true

    var body: some View {
        RegionDirectionReadout()
            .environment(\.layoutDirection,
                         isRightToLeft ? .rightToLeft : .leftToRight)
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Right-to-left", isOn: $isRightToLeft)
                    DemoHint("""
                        Both lists show the occlusion regions. In a \
                        right-to-left layout only the .mirrors frames move.
                        """)
                }
                .padding()
                .background(.bar)
            }
    }
}

#endif
