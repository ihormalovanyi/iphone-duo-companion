//
//  DemoCatalogView.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI

/// The root of DuoLab: every demo, grouped by chapter.
struct DemoCatalogView: View {
    @State private var path: [Demo] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(Demo.chapters, id: \.self) { chapter in
                    Section(Demo.chapterTitle(chapter)) {
                        ForEach(demos(in: chapter)) { demo in
                            NavigationLink(value: demo) {
                                DemoRow(demo: demo)
                            }
                        }
                    }
                }
            }
            .navigationTitle("DuoLab")
            .navigationDestination(for: Demo.self) { demo in
                DemoDestination(demo: demo)
                    .navigationTitle(demo.title)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .task { await openLaunchDemo() }
    }

    private func demos(in chapter: Int) -> [Demo] {
        Demo.allCases.filter { $0.chapter == chapter }
    }

    /// Debug builds can open one demo at launch, because scripted taps
    /// don't reach apps in the iPhone Duo simulator:
    /// `SIMCTL_CHILD_DUOLAB_DEMO=hingeReadout xcrun simctl launch ...`
    /// The demo is pushed once the list is on screen, the way a person
    /// reaches it, rather than restored as the initial path.
    private func openLaunchDemo() async {
        #if DEBUG
        let name = ProcessInfo.processInfo.environment["DUOLAB_DEMO"]
        guard let demo = name.flatMap(Demo.init(rawValue:)), path.isEmpty
        else { return }
        try? await Task.sleep(for: .milliseconds(600))
        path.append(demo)
        #endif
    }
}

private struct DemoRow: View {
    let demo: Demo

    var body: some View {
        Label {
            HStack {
                Text(demo.title)
                if demo.info.needsIOS27_1 {
                    Spacer()
                    Text("27.1")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        } icon: {
            Image(systemName: demo.info.systemImage)
        }
    }
}
