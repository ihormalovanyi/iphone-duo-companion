//
//  Ch12Scenes.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 12: more than one window, and the phases of each scene.
//

import SwiftUI

// MARK: - Open a window

// snippet:begin ch12-open-window
/// Offers a second window where the platform reports multiple-window
/// support. Elsewhere the same content opens in a sheet instead of the
/// button doing nothing. SwiftUI gives the caller no error from
/// openWindow (it logs a runtime error), so check before you call it.
struct OpenScratchpadButton: View {
    @Environment(\.supportsMultipleWindows) private var supportsWindows
    @Environment(\.openWindow) private var openWindow
    @State private var showsSheet = false

    var body: some View {
        Button("Open Scratchpad",
               systemImage: "plus.rectangle.on.rectangle") {
            if supportsWindows {
                openWindow(id: ScratchpadWindow.sceneID)
            } else {
                showsSheet = true
            }
        }
        .sheet(isPresented: $showsSheet) {
            ScratchpadWindow()
        }
    }
}
// snippet:end ch12-open-window

/// The content of DuoLab's second window group.
struct ScratchpadWindow: View {
    static let sceneID = "scratchpad"

    @State private var note = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextField("Jot something down", text: $note, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                ScenePhaseLog()
            }
            .navigationTitle("Scratchpad")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct OpenWindowScreen: View {
    @Environment(\.supportsMultipleWindows) private var supportsWindows

    var body: some View {
        Form {
            Section {
                OpenScratchpadButton()
            } footer: {
                DemoHint("""
                    New windows open on the inner display only. Try the \
                    button closed and open.
                    """)
            }
            Section("Environment") {
                LabeledContent("supportsMultipleWindows",
                               value: supportsWindows ? "true" : "false")
            }
        }
    }
}

// MARK: - Scene phase log

// snippet:begin ch12-scene-phase-log
/// Logs every phase change of the scene this view lives in. Put DuoLab
/// next to another app in Split View, then tap the other app, to see
/// what a scene reports while it stays on screen.
struct ScenePhaseLog: View {
    struct Entry: Identifiable {
        let id = UUID()
        let phase: ScenePhase
        let date: Date
    }

    @Environment(\.scenePhase) private var scenePhase
    @State private var entries: [Entry] = []

    var body: some View {
        List(entries.reversed()) { entry in
            LabeledContent(String(describing: entry.phase)) {
                Text(entry.date,
                     format: .dateTime.hour().minute().second())
            }
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            entries.append(Entry(phase: phase, date: .now))
        }
    }
}
// snippet:end ch12-scene-phase-log

struct ScenePhaseLogScreen: View {
    var body: some View {
        ScenePhaseLog()
            .safeAreaInset(edge: .bottom) {
                DemoHint("""
                    Pull down Control Center, switch apps, or use Split \
                    View. Newest entries first.
                    """)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.bar)
            }
    }
}
