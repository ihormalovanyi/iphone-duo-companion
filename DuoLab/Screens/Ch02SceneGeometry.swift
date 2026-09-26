//
//  Ch02SceneGeometry.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 2: where an app's size comes from, and why UIScreen.main is
//  the wrong answer on iPhone Duo.
//

import SwiftUI
import UIKit

// snippet:begin ch02-scene-size-swiftui
extension View {
    /// Attach to the scene's root view. Calls `action` with the scene's
    /// size, and again whenever the scene resizes: when the device
    /// opens or closes, rotates, or joins Split View.
    func onSceneSizeChange(
        _ action: @escaping (CGSize) -> Void
    ) -> some View {
        background {
            // On the root view, a reader that ignores the safe area
            // spans the whole scene.
            GeometryReader { _ in
                Color.clear
                    .onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { size in
                        action(size)
                    }
            }
            .ignoresSafeArea()
        }
    }
}
// snippet:end ch02-scene-size-swiftui

// snippet:begin ch02-scene-phase
/// Each window scene has its own phase. Save work when the scene goes
/// to the background.
struct ScenePhaseReadout: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var lastSave: Date?

    var body: some View {
        Group {
            LabeledContent("This scene", value: "\(scenePhase)")
            LabeledContent("Last save", value: lastSaveText)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                lastSave = .now
            }
        }
    }

    private var lastSaveText: String {
        lastSave?.formatted(date: .omitted, time: .standard) ?? "never"
    }
}
// snippet:end ch02-scene-phase

/// Compares the scene size SwiftUI reports with what UIKit reports for
/// the window scene, its screen, and the deprecated main screen.
struct SceneGeometryScreen: View {
    @State private var sceneSize = CGSize.zero
    @State private var windowScene: UIWindowScene?

    var body: some View {
        Form {
            Section {
                LabeledContent("Scene size", value: DuoFormat.size(sceneSize))
            } header: {
                Text("SwiftUI")
            } footer: {
                DemoHint("Measured with `onSceneSizeChange(_:)`.")
            }

            Section {
                LabeledContent("Effective geometry") {
                    Text(windowScene.map {
                        DuoFormat.size(
                            $0.effectiveGeometry.coordinateSpace.bounds.size
                        )
                    } ?? "–")
                }
                LabeledContent("windowScene.screen") {
                    Text(windowScene.map {
                        DuoFormat.size($0.screen.bounds.size)
                    } ?? "–")
                }
                LabeledContent("UIScreen.main") {
                    Text(DuoFormat.size(LegacyScreen.mainBounds.size))
                        .foregroundStyle(
                            mainScreenDisagrees ? .red : .primary
                        )
                }
            } header: {
                Text("UIKit")
            } footer: {
                DemoHint("""
                    Open the device: `UIScreen.main` is deprecated and can \
                    keep reporting the outer display while the app runs on \
                    the inner one. Red means it disagrees with the scene.
                    """)
            }

            Section("Scene phase") {
                ScenePhaseReadout()
            }
        }
        .onSceneSizeChange { sceneSize = $0 }
        .background {
            WindowSceneReader { windowScene = $0 }
                .frame(width: 0, height: 0)
        }
    }

    /// Whether the main screen's bounds match neither orientation of
    /// the scene's size.
    private var mainScreenDisagrees: Bool {
        let main = LegacyScreen.mainBounds.size
        let flipped = CGSize(width: main.height, height: main.width)
        return sceneSize != .zero && main != sceneSize && flipped != sceneSize
    }
}
