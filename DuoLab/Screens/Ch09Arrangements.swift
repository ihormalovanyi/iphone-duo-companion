//
//  Ch09Arrangements.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 9: arrangement views, split and overlay.
//

import SwiftUI

// iOS 27.1 symbols don't compile for Mac Catalyst in Xcode 27.1 beta
// (185924957); see Chapter 19.
#if !targetEnvironment(macCatalyst)

// MARK: - Stand-in content

struct PlayerPanel: View {
    var body: some View {
        DemoPanel(title: "Player", systemImage: "play.circle", tint: .pink)
    }
}

struct UpNextPanel: View {
    var body: some View {
        DemoPanel(title: "Up Next", systemImage: "list.bullet", tint: .orange)
    }
}

struct ConversationPanel: View {
    var body: some View {
        DemoPanel(title: "Conversation", systemImage: "bubble.left.and.bubble.right",
                  tint: .green)
    }
}

struct PhotosPanel: View {
    var body: some View {
        DemoPanel(title: "Photos", systemImage: "photo.on.rectangle", tint: .blue)
    }
}

struct PhotoPanel: View {
    var body: some View {
        DemoPanel(title: "Photo", systemImage: "photo", tint: .purple)
    }
}

struct InfoPanel: View {
    var body: some View {
        DemoPanel(title: "Info", systemImage: "info.circle", tint: .gray)
    }
}

struct ChartPanel: View {
    var body: some View {
        DemoPanel(title: "Chart, ideal width 280 pt",
                  systemImage: "chart.xyaxis.line", tint: .teal)
            .frame(idealWidth: 280, idealHeight: 280)
    }
}

struct NewsPanel: View {
    var body: some View {
        DemoPanel(title: "News", systemImage: "newspaper", tint: .indigo)
    }
}

struct MapCanvas: View {
    var body: some View {
        DemoPanel(title: "Map", systemImage: "map", tint: .mint)
    }
}

struct MapControlsPanel: View {
    var body: some View {
        VStack(spacing: 12) {
            Button("Locate", systemImage: "location") {}
            Button("Layers", systemImage: "square.3.layers.3d") {}
            Button("Directions", systemImage: "arrow.triangle.turn.up.right.diamond") {}
        }
        .labelStyle(.iconOnly)
        .font(.title2)
        .padding(12)
        .background(.regularMaterial, in: .capsule)
    }
}

// MARK: - Basic

// snippet:begin ch09-arrangement-basic
/// A player and its queue. The arrangement picks side by side, stacked,
/// or layered from the context: size classes, aspect ratio and an
/// active fold. Keep navigation outside it: this view lives inside a
/// NavigationStack, never the other way around.
@available(iOS 27.1, *)
struct NowPlayingView: View {
    var body: some View {
        ArrangementView {
            PlayerPanel()
        } secondary: {
            UpNextPanel()
        }
    }
}
// snippet:end ch09-arrangement-basic

enum ArrangementStyleChoice: String, CaseIterable, Identifiable {
    case automatic, split, overlay

    var id: Self { self }
}

@available(iOS 27.1, *)
extension View {
    /// Applies one of the three built-in styles, chosen at run time.
    @ViewBuilder
    func arrangementStyle(_ choice: ArrangementStyleChoice) -> some View {
        switch choice {
        case .automatic: arrangementViewStyle(.automatic)
        case .split: arrangementViewStyle(.split)
        case .overlay: arrangementViewStyle(.overlay)
        }
    }
}

@available(iOS 27.1, *)
struct ArrangementBasicScreen: View {
    @State private var style = ArrangementStyleChoice.automatic

    var body: some View {
        NowPlayingView()
            .arrangementStyle(style)
            .padding()
            .safeAreaInset(edge: .top) {
                Picker("Style", selection: $style) {
                    ForEach(ArrangementStyleChoice.allCases) { choice in
                        Text(choice.rawValue.capitalized).tag(choice)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }
    }
}

// MARK: - Split ratio

// snippet:begin ch09-split-ratio
/// The conversation takes a share of the split; the photos take the
/// rest. The view with the highest layout priority is sized first,
/// and a share that doesn't fit gets the space that is left.
@available(iOS 27.1, *)
struct ConversationWithPhotos: View {
    var conversationShare: CGFloat = 0.3

    var body: some View {
        ArrangementView {
            ConversationPanel()
                .splitArrangementLayoutRatio(conversationShare)
        } secondary: {
            PhotosPanel()
        }
        .arrangementViewStyle(.split)
    }
}
// snippet:end ch09-split-ratio

/// The same idea with a range per axis instead of one share.
@available(iOS 27.1, *)
struct ConversationWithPhotosRange: View {
    var body: some View {
        ArrangementView {
            ConversationPanel()
                .splitArrangementLayoutRatio(
                    minHorizontal: 0.25, idealHorizontal: 0.33,
                    maxHorizontal: 0.5, idealVertical: 0.4)
        } secondary: {
            PhotosPanel()
        }
        .arrangementViewStyle(.split)
    }
}

@available(iOS 27.1, *)
struct SplitRatioScreen: View {
    @State private var share = 0.3
    @State private var usesRange = false

    var body: some View {
        Group {
            if usesRange {
                ConversationWithPhotosRange()
            } else {
                ConversationWithPhotos(conversationShare: share)
            }
        }
        .padding()
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                Toggle("Use a range per axis", isOn: $usesRange)
                if !usesRange {
                    Slider(value: $share, in: 0.1...0.9) {
                        Text("Share")
                    } minimumValueLabel: {
                        Text("10%")
                    } maximumValueLabel: {
                        Text("90%")
                    }
                }
            }
            .padding()
            .background(.bar)
        }
    }
}

// MARK: - Split size

// snippet:begin ch09-split-size
/// The photo gets its ideal size when there is room, clamped to a
/// minimum and a maximum; the info panel takes the rest. Width limits
/// apply to side-by-side splits, height limits to stacked ones.
@available(iOS 27.1, *)
struct PhotoWithInfo: View {
    var body: some View {
        ArrangementView {
            PhotoPanel()
                .splitArrangementLayoutSize(
                    minWidth: 200, idealWidth: 320, maxWidth: 400,
                    minHeight: 240, idealHeight: 360)
        } secondary: {
            InfoPanel()
        }
        .arrangementViewStyle(.split)
    }
}
// snippet:end ch09-split-size

@available(iOS 27.1, *)
struct SplitSizeScreen: View {
    var body: some View {
        PhotoWithInfo()
            .padding()
    }
}

// MARK: - Split fixed size

// snippet:begin ch09-split-fixed-size
/// The chart asks for its ideal width in a side-by-side split and lets
/// its height follow the container. It is a preference: the
/// arrangement can still shrink it for a higher-priority view.
@available(iOS 27.1, *)
struct ChartWithNews: View {
    var body: some View {
        ArrangementView {
            ChartPanel()
                .splitArrangementFixedLayoutSize(horizontal: true,
                                                 vertical: false)
        } secondary: {
            NewsPanel()
        }
        .arrangementViewStyle(.split)
    }
}
// snippet:end ch09-split-fixed-size

@available(iOS 27.1, *)
struct SplitFixedSizeScreen: View {
    var body: some View {
        ChartWithNews()
            .padding()
    }
}

// MARK: - Split axes

// snippet:begin ch09-split-axes
/// A split that only ever places its views side by side, with details
/// that stack themselves across the split's axis.
@available(iOS 27.1, *)
struct AlbumView: View {
    var body: some View {
        ArrangementView {
            DemoPanel(title: "Tracks", systemImage: "music.note.list")
        } secondary: {
            AlbumDetails()
        }
        .arrangementViewStyle(.split.axes(.horizontal))
    }
}

@available(iOS 27.1, *)
struct AlbumDetails: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Album Details")
                .font(.headline)
            AxisAdaptiveStack {
                DemoPanel(title: "Artwork", systemImage: "photo")
                DemoPanel(title: "Credits", systemImage: "person.3")
            }
        }
    }
}

/// Stacks its content vertically in a side-by-side split and side by
/// side in a stacked one; the axis is nil outside a split.
@available(iOS 27.1, *)
struct AxisAdaptiveStack<Content: View>: View {
    @Environment(\.splitArrangementAxis) private var axis
    @ViewBuilder let content: Content

    var body: some View {
        let layout = axis == .horizontal
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))
        layout { content }
    }
}
// snippet:end ch09-split-axes

@available(iOS 27.1, *)
struct SplitAxesScreen: View {
    var body: some View {
        AlbumView()
            .padding()
            .safeAreaInset(edge: .bottom) {
                DemoHint("""
                    Only a side-by-side split is allowed. In a tall scene \
                    the arrangement can't split and shows the tracks \
                    alone; see the next demo.
                    """)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.bar)
            }
    }
}

// MARK: - Overlay edge

// snippet:begin ch09-overlay-edge
/// Map controls layered over the map. When a fold turns the overlay
/// into a side-by-side layout, the controls, the primary, move to the
/// leading side of a vertical fold instead of the default trailing one.
@available(iOS 27.1, *)
struct MapWithControls: View {
    var body: some View {
        ArrangementView {
            MapControlsPanel()
                .overlayArrangementEdge(HorizontalEdge.leading)
        } secondary: {
            MapCanvas()
        }
        .arrangementViewStyle(.overlay)
    }
}
// snippet:end ch09-overlay-edge

@available(iOS 27.1, *)
struct OverlayEdgeScreen: View {
    var body: some View {
        MapWithControls()
            .padding()
    }
}

// MARK: - Overlay z-index

// snippet:begin ch09-overlay-zindex
/// The queue collapses to its header while it's layered over the
/// player, where a higher z-index draws on top, and lists its tracks
/// when a fold puts it beside the player. A subview of the
/// arrangement's child reads the z-index.
@available(iOS 27.1, *)
struct QueuePanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Up Next", systemImage: "list.bullet")
                .font(.headline)
            QueueTracks()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: .rect(cornerRadius: 20))
    }
}

@available(iOS 27.1, *)
struct QueueTracks: View {
    @Environment(\.overlayArrangementZIndex) private var zIndex

    var body: some View {
        if zIndex == 0 {
            ForEach(1...6, id: \.self) { Text("Track \($0)") }
        }
    }
}
// snippet:end ch09-overlay-zindex

@available(iOS 27.1, *)
struct OverlayZIndexScreen: View {
    var body: some View {
        ArrangementView {
            QueuePanel()
        } secondary: {
            PlayerPanel()
        }
        .arrangementViewStyle(.overlay)
        .padding()
        .safeAreaInset(edge: .bottom) {
            DemoHint("""
                Layered, the queue shows its header only. Fold the device \
                partway and it moves beside the player and lists tracks.
                """)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.bar)
        }
    }
}

// MARK: - Custom style

// snippet:begin ch09-custom-style
/// A custom style that adds chrome to `.split`: each view gets its own
/// card. It nests an ArrangementView rather than laying the views out
/// itself; no source says yet whether nesting is supported.
@available(iOS 27.1, *)
struct CardSplitStyle: ArrangementViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ArrangementView {
            configuration.primary
                .padding()
                .background(.fill.tertiary, in: .rect(cornerRadius: 24))
        } secondary: {
            configuration.secondary
                .padding()
                .background(.fill.quaternary, in: .rect(cornerRadius: 24))
        }
        .arrangementViewStyle(.split)
    }
}

@available(iOS 27.1, *)
extension ArrangementViewStyle where Self == CardSplitStyle {
    static var cardSplit: CardSplitStyle { CardSplitStyle() }
}
// snippet:end ch09-custom-style

@available(iOS 27.1, *)
struct CustomStyleScreen: View {
    var body: some View {
        ArrangementView {
            Label("Primary", systemImage: "1.circle")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } secondary: {
            Label("Secondary", systemImage: "2.circle")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .arrangementViewStyle(.cardSplit)
        .padding()
    }
}

// MARK: - Pitfall: the secondary vanishes

// snippet:begin ch09-secondary-vanishes
/// Reproduces a pitfall. A split restricted to side by side can't split
/// a tall scene, so it shows the primary alone and the secondary
/// vanishes. If the secondary matters, allow both axes, or make sure
/// its content is reachable from the primary too.
@available(iOS 27.1, *)
struct TracksAndLyrics: View {
    var restrictsToSideBySide = true

    var body: some View {
        ArrangementView {
            DemoPanel(title: "Tracks", systemImage: "music.note.list")
        } secondary: {
            DemoPanel(title: "Lyrics", systemImage: "quote.bubble",
                      tint: .orange)
        }
        .arrangementViewStyle(.split.axes(axes))
    }

    private var axes: Axis.Set {
        restrictsToSideBySide ? .horizontal : [.horizontal, .vertical]
    }
}
// snippet:end ch09-secondary-vanishes

@available(iOS 27.1, *)
struct SecondaryVanishesScreen: View {
    @State private var restricts = true

    var body: some View {
        TracksAndLyrics(restrictsToSideBySide: restricts)
            .padding()
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Side by side only", isOn: $restricts)
                    DemoHint("""
                        Closed, the scene is tall: with the restriction on, \
                        Lyrics disappears.
                        """)
                }
                .padding()
                .background(.bar)
            }
    }
}

#endif
