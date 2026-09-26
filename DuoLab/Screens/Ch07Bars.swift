//
//  Ch07Bars.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 7: vertical toolbars and tab bars.
//

import SwiftUI

// MARK: - Ordering

// snippet:begin ch07-toolbar-ordering
/// The order a vertical bar uses, top to bottom: the Close button, the
/// prominent Done action, then the remaining groups as they were
/// grouped. Items from the bottom bar go to the bottom of the column.
struct ComposeNoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""

    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .padding(.horizontal)
                .navigationTitle("New Note")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close", systemImage: "xmark") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarPinnedTrailing) {
                        Button("Done", systemImage: "checkmark") {
                            dismiss()
                        }
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button("Attach", systemImage: "paperclip") {}
                        Button("Format", systemImage: "textformat") {}
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("Checklist", systemImage: "checklist") {}
                        Button("Table", systemImage: "tablecells") {}
                    }
                }
        }
    }
}
// snippet:end ch07-toolbar-ordering

struct ToolbarOrderingScreen: View {
    @State private var isComposing = false

    var body: some View {
        Form {
            Section {
                Button("New Note", systemImage: "square.and.pencil") {
                    isComposing = true
                }
            } footer: {
                DemoHint("""
                    On the outer display the sheet's bar goes vertical: \
                    Close, Done, the top group, a spacer, then the bottom \
                    group.
                    """)
            }
        }
        .sheet(isPresented: $isComposing) {
            ComposeNoteSheet()
        }
    }
}

// MARK: - Overflow and priority

// snippet:begin ch07-overflow-priority
/// Items leave a crowded vertical bar from the bottom up; priorities
/// change that order. Actions that only ever belong in the overflow
/// menu go into the system's one overflow menu, not an ellipsis menu
/// of your own.
struct MailToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem {
            Button("Compose", systemImage: "square.and.pencil") {}
        }
        .visibilityPriority(.high)

        ToolbarItemGroup {
            Button("Flag", systemImage: "flag") {}
            Button("Move", systemImage: "folder") {}
        }
        .visibilityPriority(.low)

        ToolbarOverflowMenu {
            Button("Mark All as Read", systemImage: "envelope.open") {}
            Button("Mailbox Settings", systemImage: "gearshape") {}
        }
    }
}
// snippet:end ch07-overflow-priority

struct OverflowScreen: View {
    var body: some View {
        List(1...40, id: \.self) { row in
            Text("Message \(row)")
        }
        .toolbar { MailToolbar() }
        .safeAreaInset(edge: .bottom) {
            DemoHint("""
                Rotate the closed device to landscape: the bar runs out \
                of room and the low-priority group overflows first, \
                Compose last.
                """)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.bar)
        }
    }
}

// MARK: - Badges

// snippet:begin ch07-badges
/// The badge carries the count, so the item stays a symbol and fits a
/// vertical bar. A count in the title would make it a text item, and
/// text items stay in the horizontal bar.
struct InboxButton: View {
    let unreadCount: Int

    var body: some View {
        Button("Inbox", systemImage: "tray") {}
            .badge(unreadCount)
    }
}
// snippet:end ch07-badges

struct BadgesScreen: View {
    @State private var unreadCount = 7

    var body: some View {
        Form {
            Stepper("Unread: \(unreadCount)", value: $unreadCount,
                    in: 0...99)
        }
        .toolbar {
            ToolbarItem {
                InboxButton(unreadCount: unreadCount)
            }
        }
    }
}

// iOS 27.1 symbols don't compile for Mac Catalyst in Xcode 27.1 beta
// (185924957); see Chapter 19.
#if !targetEnvironment(macCatalyst)

// MARK: - Axis behavior

// snippet:begin ch07-axis-behavior
/// A custom profile view opts into the vertical bar. The Select button
/// stays horizontal, because it switches between a symbol and the text
/// Done; with no horizontal bar at all it isn't shown.
@available(iOS 27.1, *)
struct PhotoGridToolbar: ToolbarContent {
    @Binding var isSelecting: Bool

    var body: some ToolbarContent {
        ToolbarItem {
            ProfileBadge(initials: "IM")
        }
        .axisBehavior(.verticalPreferred)

        ToolbarItem {
            if isSelecting {
                Button("Done") { isSelecting = false }
            } else {
                Button("Select", systemImage: "checkmark.circle") {
                    isSelecting = true
                }
            }
        }
        .axisBehavior(.horizontalOnly)
    }
}
// snippet:end ch07-axis-behavior

/// A compact custom view that fits a vertical bar's fixed width.
struct ProfileBadge: View {
    let initials: String

    var body: some View {
        Text(initials)
            .font(.caption.bold())
            .frame(width: 32, height: 32)
            .background(.tint.opacity(0.2), in: .circle)
            .accessibilityLabel("Profile")
    }
}

@available(iOS 27.1, *)
struct AxisBehaviorScreen: View {
    @State private var isSelecting = false

    var body: some View {
        List(1...40, id: \.self) { row in
            Label("Photo \(row)", systemImage: isSelecting
                  ? "circle" : "photo")
        }
        .toolbar { PhotoGridToolbar(isSelecting: $isSelecting) }
    }
}

// MARK: - Vertical bar edge

// snippet:begin ch07-vertical-edge-custom-view
/// A floating tool palette that sits on the same side as the system's
/// vertical bar, so every control stays under one thumb and the content
/// keeps the rest of the display. `nil` means this context never shows
/// a vertical bar.
@available(iOS 27.1, *)
struct FloatingPalette: View {
    @Environment(\.toolbarVerticalEdge) private var barEdge

    var body: some View {
        VStack(spacing: 16) {
            Button("Pen", systemImage: "pencil.tip") {}
            Button("Marker", systemImage: "highlighter") {}
            Button("Eraser", systemImage: "eraser") {}
        }
        .labelStyle(.iconOnly)
        .padding(12)
        .background(.regularMaterial, in: .capsule)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity,
               alignment: barEdge == .leading ? .leading : .trailing)
    }
}
// snippet:end ch07-vertical-edge-custom-view

@available(iOS 27.1, *)
struct VerticalEdgeScreen: View {
    @Environment(\.toolbarVerticalEdge) private var barEdge

    var body: some View {
        ZStack {
            Canvas { context, size in
                // A plain drawing surface under the palette.
                for x in stride(from: 0, through: size.width, by: 24) {
                    context.stroke(
                        Path { $0.addLines([CGPoint(x: x, y: 0),
                                            CGPoint(x: x, y: size.height)]) },
                        with: .color(.secondary.opacity(0.2)))
                }
            }
            FloatingPalette()
        }
        .toolbar {
            ToolbarItem {
                Button("Undo", systemImage: "arrow.uturn.backward") {}
            }
        }
        .safeAreaInset(edge: .top) {
            Text("toolbarVerticalEdge: "
                 + (barEdge.map { String(describing: $0) } ?? "nil"))
                .font(.footnote.monospaced())
                .padding(8)
        }
    }
}

// MARK: - Vertical bar opt-out

// snippet:begin ch07-vertical-behavior-opt-out
/// A bottom-heavy keypad reads better with horizontal bars, so this
/// screen opts out, as a constant. A NavigationStack uses its top view,
/// so going back restores vertical bars.
@available(iOS 27.1, *)
struct KeypadScreen: View {
    var body: some View {
        KeypadGrid()
            .toolbar {
                Button("History", systemImage: "clock") {}
            }
            .toolbarVerticalBehavior(.disabled)
    }
}
// snippet:end ch07-vertical-behavior-opt-out

struct KeypadGrid: View {
    private let keys = ["7", "8", "9", "4", "5", "6", "1", "2", "3",
                        "0", ".", "="]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 3),
                  spacing: 12) {
            ForEach(keys, id: \.self) { key in
                Text(key)
                    .font(.title.monospacedDigit())
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(.fill.tertiary, in: .capsule)
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

// MARK: - Compression

// snippet:begin ch07-compression-behavior
/// When a vertical bar holds both a tab bar and toolbar items and runs
/// out of room, iOS keeps the tab bar and compresses the items first.
/// A task-focused screen can ask for the opposite.
struct RecentFilesTab: View {
    var body: some View {
        NavigationStack {
            List(1...40, id: \.self) { Text("Document \($0)") }
                .navigationTitle("Recents")
                .toolbar { FileActions() }
                .gated { view in
                    if #available(iOS 27.1, *) {
                        view.toolbarVerticalCompressionBehavior(
                            .prefersToolbarItems
                        )
                    } else {
                        view
                    }
                }
        }
    }
}
// snippet:end ch07-compression-behavior

struct CompressionScreen: View {
    var body: some View {
        FullScreenDemoLauncher(
            buttonTitle: "Open Files Tabs",
            hint: """
                Rotate the closed device to landscape. The Recents tab \
                keeps its four toolbar items and compresses the tab bar; \
                the Shared tab keeps the default and loses items first.
                """
        ) {
            TabView {
                Tab("Recents", systemImage: "clock") {
                    RecentFilesTab()
                }
                Tab("Shared", systemImage: "person.2") {
                    DefaultCompressionTab()
                }
                Tab("Browse", systemImage: "folder") {
                    TabDemoPage(title: "Browse")
                }
                Tab("Tags", systemImage: "tag") {
                    TabDemoPage(title: "Tags")
                }
            }
        }
    }
}

/// The same toolbar with the default compression behavior.
struct DefaultCompressionTab: View {
    var body: some View {
        NavigationStack {
            List(1...40, id: \.self) { Text("Shared document \($0)") }
                .navigationTitle("Shared")
                .toolbar { FileActions() }
        }
    }
}

/// Four symbol items that compete with the tab bar for the column.
struct FileActions: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItemGroup {
            Button("New Folder", systemImage: "folder.badge.plus") {}
            Button("Scan", systemImage: "doc.viewfinder") {}
            Button("Sort", systemImage: "arrow.up.arrow.down") {}
            Button("Select", systemImage: "checkmark.circle") {}
        }
    }
}

#endif
