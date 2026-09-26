//
//  Ch05SafeAreas.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 5: asymmetric safe areas, backgrounds that bleed, concentric
//  corners, and the background extension effect.
//

import SwiftUI

// MARK: - Safe area per edge

// snippet:begin ch05-safe-area-per-edge
/// Reads every safe-area inset on its own. On iPhone Duo the leading
/// and trailing insets often differ (whenever a vertical bar is on
/// screen), so never derive one edge from another.
struct SafeAreaReadout: View {
    @State private var insets = EdgeInsets()

    var body: some View {
        Grid(alignment: .leading, verticalSpacing: 8) {
            row("Top", insets.top)
            row("Leading", insets.leading)
            row("Bottom", insets.bottom)
            row("Trailing", insets.trailing)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onGeometryChange(for: EdgeInsets.self) { proxy in
            proxy.safeAreaInsets
        } action: { newInsets in
            insets = newInsets
        }
    }

    private func row(_ edge: String, _ inset: CGFloat) -> some View {
        GridRow {
            Text(edge)
            Text("\(Int(inset.rounded())) pt")
                .monospacedDigit()
        }
    }
}
// snippet:end ch05-safe-area-per-edge

struct SafeAreaEdgesScreen: View {
    @State private var isRightToLeft = false

    var body: some View {
        // The toggle lives in the navigation bar, not in a bottom
        // safe-area inset, so Bottom shows only the system's inset.
        SafeAreaReadout()
            .font(.title3)
            .environment(
                \.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight
            )
            .overlay(alignment: .top) {
                DemoHint("""
                    Bars stay on the same physical side in right-to-left \
                    languages. Watch which logical edge reports the bar's \
                    inset. For the full effect, run the scheme with a \
                    right-to-left App Language.
                    """)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle("Right-to-left", isOn: $isRightToLeft)
                }
            }
    }
}

// MARK: - Background bleed

// snippet:begin ch05-background-bleed
/// Foreground content stays inside the safe area; only the background
/// bleeds under the bars, the status bar and the camera.
struct BleedingHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("iPhone Duo")
                .font(.largeTitle.bold())
            Text("Text stays clear of every bar and camera.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity,
               alignment: .topLeading)
        .padding()
        .foregroundStyle(.white)
        .background {
            LinearGradient(colors: [.indigo, .teal],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
        }
    }
}
// snippet:end ch05-background-bleed

struct BackgroundBleedScreen: View {
    var body: some View {
        BleedingHeader()
    }
}

// MARK: - Concentric corners

// snippet:begin ch05-concentric-corners
/// Nested views whose corners stay parallel to their container's.
/// A concentric radius is the container shape's corner radius minus
/// the distance between corners; only the top view sets a minimum.
struct ConcentricPanels: View {
    var body: some View {
        VStack(spacing: 8) {
            ConcentricRectangle(corners: .concentric(minimum: 8),
                                isUniform: true)
                .fill(.tint.opacity(0.3))
            HStack(spacing: 8) {
                ConcentricRectangle()
                    .fill(.tint.opacity(0.5))
                ConcentricRectangle()
                    .fill(.tint.opacity(0.7))
            }
        }
        .padding(8)
        .background(.fill.secondary, in: .rect(cornerRadius: 36))
        .containerShape(.rect(cornerRadius: 36))
    }
}
// snippet:end ch05-concentric-corners

struct ConcentricCornersScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            ConcentricPanels()
                .frame(maxHeight: 360)

            // GeometryProxy.concentricCornerRadii (iOS 27.0) returns the
            // radii ConcentricRectangle draws with. It is read here the
            // way Apple's documentation shows: on a reader that has the
            // container shape itself.
            GeometryReader { proxy in
                let radii = proxy.concentricCornerRadii
                Canvas { context, size in
                    guard let radii else { return }
                    let path = Path(roundedRect: CGRect(origin: .zero,
                                                        size: size),
                                    cornerRadii: radii)
                    context.fill(path, with: .color(.accentColor.opacity(0.3)))
                }
                .overlay {
                    Text(describe(radii))
                        .font(.callout.monospacedDigit())
                }
            }
            .frame(height: 72)
            .containerShape(.rect(cornerRadius: 24))
        }
        .padding()
    }

    private func describe(_ radii: RectangleCornerRadii?) -> String {
        guard let radii else { return "No container shape" }
        return [radii.topLeading, radii.topTrailing,
                radii.bottomLeading, radii.bottomTrailing]
            .map(DuoFormat.number)
            .joined(separator: " · ")
    }
}

// MARK: - Background extension

// snippet:begin ch05-background-extension
/// A hero header that continues under a vertical bar and the status
/// bar. backgroundExtensionEffect() mirrors and blurs the artwork into
/// the safe area around it; the title stays inside the safe area.
struct HeroHeader: View {
    var body: some View {
        HeroArtwork()
            .backgroundExtensionEffect()
            .frame(height: 260)
            .overlay(alignment: .bottomLeading) {
                Text("Fold Lines")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .padding()
            }
    }
}
// snippet:end ch05-background-extension

/// Abstract artwork drawn in code, so the demo ships no images.
struct HeroArtwork: View {
    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.6, 0.4], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1],
            ],
            colors: [
                .indigo, .purple, .pink,
                .blue, .teal, .orange,
                .cyan, .mint, .yellow,
            ]
        )
    }
}

struct BackgroundExtensionScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HeroHeader()
                DemoHint("""
                    With a vertical bar on the side, the artwork extends \
                    under it instead of stopping at the safe area.
                    """)
                .padding(.horizontal)
            }
        }
    }
}
