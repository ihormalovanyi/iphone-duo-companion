//
//  Ch04FluidLayout.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 4: fluid layout from size classes and container sizes.
//

import SwiftUI

// MARK: - ViewThatFits

// snippet:begin ch04-viewthatfits
/// Three stat cards in a row when the row fits, stacked when it
/// doesn't. ViewThatFits picks the first child that fits the width it
/// is offered, so the choice follows the scene, not the device.
struct StatCardRow: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) { cards }
            VStack(spacing: 12) { cards }
        }
    }

    @ViewBuilder private var cards: some View {
        StatCard(title: "Steps", value: "8,412")
        StatCard(title: "Distance", value: "6.1 km")
        StatCard(title: "Floors", value: "12")
    }
}

/// The minimum width decides where the row gives way to the stack.
struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold())
                .fixedSize()
        }
        .frame(minWidth: 150, maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.fill.tertiary, in: .rect(cornerRadius: 16))
    }
}
// snippet:end ch04-viewthatfits

struct ViewThatFitsScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                StatCardRow()
                DemoHint("""
                    The outer display (466 pt wide in portrait) gets the \
                    stack; the inner display gets the row.
                    """)
            }
            .padding()
        }
    }
}

// MARK: - AnyLayout with lifted state

// snippet:begin ch04-anylayout-lifted-state
/// An editor and its preview side by side in a regular width, stacked
/// in a compact one. AnyLayout keeps the same children when the layout
/// changes, and the draft lives above the layout, so opening or closing
/// the device never loses what the person typed.
struct NoteEditor: View {
    @Environment(\.horizontalSizeClass) private var widthClass
    @State private var draft = "Notes survive a fold."

    var body: some View {
        let layout = widthClass == .regular
            ? AnyLayout(HStackLayout(alignment: .top, spacing: 16))
            : AnyLayout(VStackLayout(spacing: 16))

        layout {
            TextField("Note", text: $draft, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            NotePreview(text: draft)
        }
        .animation(.default, value: widthClass)
    }
}
// snippet:end ch04-anylayout-lifted-state

struct NotePreview: View {
    let text: String

    var body: some View {
        Text(text.isEmpty ? "Preview" : text)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
            .padding()
            .background(.fill.tertiary, in: .rect(cornerRadius: 12))
    }
}

struct AnyLayoutScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                NoteEditor()
                DemoHint("""
                    Type something, then open or close the device. The \
                    layout changes; the text and the keyboard focus stay.
                    """)
            }
            .padding()
        }
    }
}

// MARK: - onGeometryChange

// snippet:begin ch04-ongeometrychange
/// Derives a column count from the width the grid actually gets. The
/// transform returns the count, not the width, so the action runs only
/// when the count changes, not on every point of a live resize.
struct AdaptiveTileGrid: View {
    let tiles: [String]
    @State private var columnCount = 2

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(), count: columnCount)
        ) {
            ForEach(tiles, id: \.self) { tile in
                Text(tile)
                    .frame(maxWidth: .infinity, minHeight: 72)
                    .background(.tint.opacity(0.15),
                                in: .rect(cornerRadius: 12))
            }
        }
        .onGeometryChange(for: Int.self) { proxy in
            max(1, Int(proxy.size.width / 150))
        } action: { count in
            columnCount = count
        }
    }
}
// snippet:end ch04-ongeometrychange

struct GeometryChangeScreen: View {
    private let tiles = (1...24).map { "Tile \($0)" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DemoHint("One column per 150 pt of width.")
                AdaptiveTileGrid(tiles: tiles)
            }
            .padding()
        }
    }
}

// MARK: - containerRelativeFrame

// snippet:begin ch04-container-relative-frame
/// A shelf that always shows two cards across in a compact width and
/// four in a regular width. Each card sizes itself against the scroll
/// view it lives in, never against the screen.
struct CardShelf: View {
    @Environment(\.horizontalSizeClass) private var widthClass
    let titles: [String]

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 12) {
                ForEach(titles, id: \.self) { title in
                    Text(title)
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(.tint.opacity(0.15),
                                    in: .rect(cornerRadius: 16))
                        .containerRelativeFrame(
                            .horizontal,
                            count: widthClass == .regular ? 4 : 2,
                            spacing: 12
                        )
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, 16, for: .scrollContent)
    }
}
// snippet:end ch04-container-relative-frame

struct ContainerRelativeFrameScreen: View {
    private let titles = (1...12).map { "Card \($0)" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CardShelf(titles: titles)
                DemoHint("""
                    Two cards across when closed, four when open. Even \
                    counts keep a card from straddling the fold.
                    """)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Pitfall: root branch

// snippet:begin ch04-antipattern-root-branch
/// Don't do this. Branching the root on the size class builds two
/// different view trees. When the class flips, which happens every time
/// the device opens or closes, SwiftUI discards the old tree and the
/// draft inside it. Use AnyLayout with the state lifted out instead.
struct BranchingNoteEditor: View {
    @Environment(\.horizontalSizeClass) private var widthClass

    var body: some View {
        if widthClass == .regular {
            HStack(alignment: .top, spacing: 16) { DraftEditor() }
        } else {
            VStack(spacing: 16) { DraftEditor() }
        }
    }
}

private struct DraftEditor: View {
    @State private var draft = "Notes survive a fold."

    var body: some View {
        TextField("Note", text: $draft, axis: .vertical)
            .textFieldStyle(.roundedBorder)
        NotePreview(text: draft)
    }
}
// snippet:end ch04-antipattern-root-branch

struct RootBranchScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DemoHint("""
                    Edit both notes, then open or close the device. Only \
                    the first one keeps your text.
                    """)
                GroupBox("AnyLayout, state lifted out") {
                    NoteEditor()
                }
                GroupBox("Root branch on the size class") {
                    BranchingNoteEditor()
                }
            }
            .padding()
        }
    }
}
