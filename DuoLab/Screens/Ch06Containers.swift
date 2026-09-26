//
//  Ch06Containers.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 6: system containers and presentations adapt on their own.
//

import SwiftUI

// MARK: - Sample data

enum Mailbox: String, CaseIterable, Identifiable, Hashable {
    case inbox, drafts, sent, archive

    var id: Self { self }
    var title: String { rawValue.capitalized }

    var systemImage: String {
        switch self {
        case .inbox: "tray"
        case .drafts: "doc"
        case .sent: "paperplane"
        case .archive: "archivebox"
        }
    }
}

struct Message: Identifiable, Hashable {
    let id: Int
    let subject: String
    let body: String

    static func samples(in mailbox: Mailbox) -> [Message] {
        (1...12).map { number in
            Message(
                id: number,
                subject: "\(mailbox.title) message \(number)",
                body: "The body of \(mailbox.title.lowercased()) message "
                    + "\(number). Fold the device to see the columns "
                    + "settle into an even split."
            )
        }
    }
}

// MARK: - NavigationSplitView

// snippet:begin ch06-navigation-split-view
/// Columns on the inner display, one navigation stack on the outer
/// display, and an even split while the device is folded. The
/// container does all of it; the app only supplies the columns.
struct MailboxSplitView: View {
    @State private var mailbox: Mailbox? = .inbox
    @State private var message: Message?

    var body: some View {
        NavigationSplitView {
            List(Mailbox.allCases, selection: $mailbox) { mailbox in
                Label(mailbox.title, systemImage: mailbox.systemImage)
            }
            .navigationTitle("Mailboxes")
        } content: {
            if let mailbox {
                List(Message.samples(in: mailbox), selection: $message) {
                    Text($0.subject).tag($0)
                }
                .navigationTitle(mailbox.title)
            }
        } detail: {
            if let message {
                ScrollView {
                    Text(message.body).padding()
                }
                .navigationTitle(message.subject)
            } else {
                ContentUnavailableView("No Message Selected",
                                       systemImage: "envelope")
            }
        }
    }
}
// snippet:end ch06-navigation-split-view

struct SplitViewScreen: View {
    var body: some View {
        FullScreenDemoLauncher(
            buttonTitle: "Open Mailboxes",
            hint: """
                Try it closed, open, and partially folded like a book. \
                Only the detail column gets a vertical bar.
                """
        ) {
            MailboxSplitView()
        }
    }
}

// MARK: - TabView sidebar

// snippet:begin ch06-tabview-sidebar-placement
/// Tabs appear on both displays by default, and lay out vertically
/// where that fits. On the inner display an app can opt into a sidebar
/// instead; this one asks for it.
struct LibraryTabs: View {
    var prefersSidebar = true

    var body: some View {
        TabView {
            Tab("Listen Now", systemImage: "play.circle") {
                TabDemoPage(title: "Listen Now")
            }
            Tab("Library", systemImage: "books.vertical") {
                TabDemoPage(title: "Library")
            }
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                TabDemoPage(title: "Search")
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .defaultTabBarPlacement(prefersSidebar ? .sidebar : .automatic)
    }
}
// snippet:end ch06-tabview-sidebar-placement

struct TabDemoPage: View {
    let title: String

    var body: some View {
        NavigationStack {
            List(1...20, id: \.self) { row in
                Text("\(title) item \(row)")
            }
            .navigationTitle(title)
        }
    }
}

struct TabSidebarScreen: View {
    @State private var prefersSidebar = true

    var body: some View {
        VStack(spacing: 0) {
            Toggle("Prefer a sidebar", isOn: $prefersSidebar)
                .padding()
            FullScreenDemoLauncher(
                buttonTitle: "Open Library",
                hint: """
                    Compare the inner and the outer display with the \
                    sidebar preferred and without it.
                    """
            ) {
                LibraryTabs(prefersSidebar: prefersSidebar)
            }
        }
    }
}

// MARK: - Sheet placement

// snippet:begin ch06-sheet-placement
/// Presents details in a sheet at the placement the person picks. On
/// the inner display a trailing sheet gets a vertical bar, while
/// centered and leading sheets keep horizontal bars.
struct PlacedSheetDemo: View {
    @State private var placement = PresentationPlacement.automatic
    @State private var isPresented = false

    var body: some View {
        Form {
            Picker("Placement", selection: $placement) {
                Text("Automatic").tag(PresentationPlacement.automatic)
                Text("Leading").tag(PresentationPlacement.leading)
                Text("Center").tag(PresentationPlacement.center)
                Text("Trailing").tag(PresentationPlacement.trailing)
            }
            Button("Show Details") { isPresented = true }
        }
        .sheet(isPresented: $isPresented) {
            DetailsSheet()
                .presentationPlacement(placement)
        }
    }
}
// snippet:end ch06-sheet-placement

struct DetailsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                LabeledContent("Opened", value: "23 Oct 2026")
                LabeledContent("Size", value: "4.2 MB")
                LabeledContent("Kind", value: "Document")
                #if !targetEnvironment(macCatalyst)
                if #available(iOS 27.1, *) {
                    VerticalBarEdgeReadout()
                }
                #endif
            }
            .navigationTitle("Details")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") { dismiss() }
                }
                ToolbarItem {
                    Button("Share", systemImage: "square.and.arrow.up") {}
                }
            }
        }
    }
}

#if !targetEnvironment(macCatalyst)
/// Shows which edge the system prefers for a vertical bar inside the
/// sheet; `nil` means this context never shows one.
@available(iOS 27.1, *)
private struct VerticalBarEdgeReadout: View {
    @Environment(\.toolbarVerticalEdge) private var barEdge

    var body: some View {
        LabeledContent(
            "toolbarVerticalEdge",
            value: barEdge.map { String(describing: $0) } ?? "nil"
        )
    }
}
#endif

struct SheetPlacementScreen: View {
    var body: some View {
        PlacedSheetDemo()
            .safeAreaInset(edge: .bottom) {
                DemoHint("""
                    Only sheets respect the placement. Open the device to \
                    compare the bars of a leading and a trailing sheet.
                    """)
                .padding()
            }
    }
}

// MARK: - Popover, menu, alert

// snippet:begin ch06-popover-menu-alert
/// Popovers, menus, alerts and dialogs move out of the fold on their
/// own when the device is partially folded. Nothing here positions
/// them by hand.
struct PresentationsDemo: View {
    @State private var showsPopover = false
    @State private var showsAlert = false
    @State private var showsDialog = false

    var body: some View {
        Form {
            Button("Show Popover") { showsPopover = true }
                .popover(isPresented: $showsPopover) {
                    Text("Popovers avoid the fold.")
                        .padding()
                        .presentationCompactAdaptation(.popover)
                }
            Menu("Show Menu") {
                Button("Copy", systemImage: "doc.on.doc") {}
                Button("Rename", systemImage: "pencil") {}
                Button("Delete", systemImage: "trash",
                       role: .destructive) {}
            }
            Button("Show Alert") { showsAlert = true }
            Button("Show Dialog") { showsDialog = true }
        }
        .alert("Discard this draft?", isPresented: $showsAlert) {
            Button("Discard", role: .destructive) {}
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Share Note", isPresented: $showsDialog) {
            Button("Copy Link") {}
            Button("Export as PDF") {}
        }
    }
}
// snippet:end ch06-popover-menu-alert

struct PopoverMenuAlertScreen: View {
    var body: some View {
        PresentationsDemo()
            .safeAreaInset(edge: .bottom) {
                DemoHint("""
                    Fold the device partway like a book: alerts move to \
                    the trailing side. Folded like a laptop, interactive \
                    elements move to the bottom half.
                    """)
                .padding()
            }
    }
}
