//
//  Ch11Poses.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 11: one screen, every pose, the same controls.
//

import SwiftUI

// iOS 27.1 symbols don't compile for Mac Catalyst in Xcode 27.1 beta
// (185924957); see Chapter 19.
#if !targetEnvironment(macCatalyst)

// snippet:begin ch11-pose-layout-matrix
/// One screen for every pose, built from size classes, the view's size
/// and the fold region, never from the hinge angle or the device model:
/// a horizontal fold (laptop), media above it and controls below; a
/// vertical fold (book), media and controls on either side; with no
/// fold, compact width gets one column, otherwise side by side if
/// wide, stacked if tall.
@available(iOS 27.1, *)
struct PoseAdaptiveScreen: View {
    @Environment(\.horizontalSizeClass) private var widthClass

    var body: some View {
        GeometryReader { proxy in
            let fold = proxy.reservedRegions(kind: .division)
                .first(where: \.isActive)?.frame
            let layout = layout(for: proxy.size, fold: fold)

            layout {
                MediaPanel()
                PlaybackControls()
            }
            .animation(.smooth, value: fold)
        }
    }

    private func layout(for size: CGSize, fold: CGRect?) -> AnyLayout {
        if let fold {
            return AnyLayout(FoldSplitLayout(fold: fold))
        }
        if widthClass == .compact {
            return AnyLayout(VStackLayout(spacing: 16))
        }
        return size.width > size.height
            ? AnyLayout(HStackLayout(spacing: 16))
            : AnyLayout(VStackLayout(spacing: 16))
    }
}
// snippet:end ch11-pose-layout-matrix

// snippet:begin ch11-fold-split-layout
/// Places the first subview before the fold and the second after it:
/// above and below a horizontal fold, leading and trailing of a
/// vertical one. The fold's frame, margins included, stays empty.
/// `fold` is relative to the layout's top-leading corner.
struct FoldSplitLayout: Layout {
    let fold: CGRect

    func sizeThatFits(
        proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize,
        subviews: Subviews, cache: inout ()
    ) {
        // Move the fold into the space `bounds` is expressed in.
        let fold = fold.offsetBy(dx: bounds.minX, dy: bounds.minY)
        let first, second: CGRect
        if fold.width > fold.height {
            // A horizontal fold: above and below it.
            first = CGRect(x: bounds.minX, y: bounds.minY,
                           width: bounds.width,
                           height: max(0, fold.minY - bounds.minY))
            second = CGRect(x: bounds.minX, y: fold.maxY,
                            width: bounds.width,
                            height: max(0, bounds.maxY - fold.maxY))
        } else {
            // A vertical fold: before and after it.
            first = CGRect(x: bounds.minX, y: bounds.minY,
                           width: max(0, fold.minX - bounds.minX),
                           height: bounds.height)
            second = CGRect(x: fold.maxX, y: bounds.minY,
                            width: max(0, bounds.maxX - fold.maxX),
                            height: bounds.height)
        }
        for (subview, frame) in zip(subviews, [first, second]) {
            subview.place(at: frame.origin,
                          proposal: ProposedViewSize(frame.size))
        }
    }
}
// snippet:end ch11-fold-split-layout

struct MediaPanel: View {
    var body: some View {
        HeroArtwork()
            .overlay(alignment: .bottomLeading) {
                Text("Now Playing")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .padding()
            }
            .clipShape(.rect(cornerRadius: 24))
    }
}

struct PlaybackControls: View {
    @State private var isPlaying = false
    @State private var progress = 0.3

    var body: some View {
        VStack(spacing: 16) {
            Slider(value: $progress)
            HStack(spacing: 32) {
                Button("Back", systemImage: "backward.fill") {}
                Button(isPlaying ? "Pause" : "Play",
                       systemImage: isPlaying ? "pause.fill" : "play.fill") {
                    isPlaying.toggle()
                }
                .font(.largeTitle)
                Button("Forward", systemImage: "forward.fill") {}
            }
            .labelStyle(.iconOnly)
            .font(.title)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.fill.tertiary, in: .rect(cornerRadius: 24))
    }
}

#endif
