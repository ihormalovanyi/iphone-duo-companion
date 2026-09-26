//
//  Components.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI

/// A short note under a demo that says what to try.
struct DemoHint: View {
    let text: LocalizedStringKey

    init(_ text: LocalizedStringKey) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}

/// Shown in place of a demo that needs a newer system or platform.
struct DemoUnavailable: View {
    let demo: Demo
    let reason: LocalizedStringKey

    var body: some View {
        ContentUnavailableView {
            Label(demo.title, systemImage: demo.info.systemImage)
        } description: {
            Text(reason)
        }
    }
}

/// A rounded, tinted panel used as stand-in content in layout demos.
/// Inside an arrangement it also shows the arrangement values it reads.
struct DemoPanel: View {
    let title: String
    var systemImage = "square.dashed"
    var tint: Color = .accentColor

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.title)
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
            #if !targetEnvironment(macCatalyst)
            if #available(iOS 27.1, *) {
                ArrangementValues()
            }
            #endif
        }
        .foregroundStyle(tint)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(tint.opacity(0.15), in: .rect(cornerRadius: 20))
    }
}

#if !targetEnvironment(macCatalyst)
/// The two arrangement environment values, as this view sees them.
@available(iOS 27.1, *)
private struct ArrangementValues: View {
    @Environment(\.splitArrangementAxis) private var axis
    @Environment(\.overlayArrangementZIndex) private var zIndex

    var body: some View {
        Text("axis " + (axis.map { String(describing: $0) } ?? "nil")
             + " · z \(zIndex)")
            .font(.caption.monospaced())
            .foregroundStyle(.secondary)
    }
}
#endif

/// Presents a container demo full screen, so it gets its own bars, with
/// a Close button below it that stays clear of those bars.
struct FullScreenDemoLauncher<Content: View>: View {
    let buttonTitle: LocalizedStringKey
    let hint: LocalizedStringKey
    @ViewBuilder let content: () -> Content
    @State private var isPresented = false

    var body: some View {
        Form {
            Section {
                Button(buttonTitle) { isPresented = true }
            } footer: {
                DemoHint(hint)
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            content()
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Button("Close Demo", systemImage: "xmark") {
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(8)
                }
        }
    }
}
