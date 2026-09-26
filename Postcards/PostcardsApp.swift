//
//  PostcardsApp.swift
//  Postcards
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Postcards is the showcase app of "Developing for iPhone Duo:
//  Approaches and Tips": one small product that uses every main
//  iPhone Duo approach from the book at once. A postcard folds, so the
//  fold of the device becomes the crease of the card.
//
//  Closed: a list with the system's vertical tab bar (Chapter 7).
//  Open, tall: the card and its back stacked (Chapters 4, 6).
//  Open, wide and folded like a book: a spread across the fold with
//  ArrangementView (Chapter 9), the stamp avoiding the camera's reserved
//  region (Chapter 8).
//  Folded like a laptop: picture on top, the message and the keyboard
//  at the bottom (Chapters 11, 17).
//  The hinge angle tilts the card as the device folds (Chapter 10).
//  Blueprint draws what the APIs report on top of any screen.
//

import SwiftUI

@main
@MainActor
struct PostcardsApp: App {
    @State private var store = PostcardStore()

    var body: some Scene {
        WindowGroup {
            if #available(iOS 27.1, *) {
                RootView()
                    .environment(store)
            } else {
                ContentUnavailableView(
                    "Postcards needs iOS 27.1",
                    systemImage: "iphone.gen3",
                    description: Text("""
                        The iPhone Duo APIs this app demonstrates ship \
                        with the iOS 27.1 SDK.
                        """))
            }
        }
    }
}
