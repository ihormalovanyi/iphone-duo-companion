//
//  RootView.swift
//  Postcards
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI

/// Three tabs. On the outer display and in the wide layout the system
/// turns this tab bar vertical (Chapter 7); the views never ask which.
@available(iOS 27.1, *)
struct RootView: View {
    @AppStorage("blueprint") private var blueprint = false

    var body: some View {
        TabView {
            Tab("Cards", systemImage: "rectangle.portrait.on.rectangle.portrait.angled") {
                CardsSplitView()
            }
            Tab("About", systemImage: "book.closed") {
                AboutView()
            }
        }
        .overlay {
            if blueprint {
                BlueprintOverlay()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .animation(.smooth, value: blueprint)
    }
}
