//
//  DuoLabApp.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI

@main
struct DuoLabApp: App {
    var body: some Scene {
        WindowGroup {
            DemoCatalogView()
        }

        // Chapter 12 opens this window with `openWindow(id:)`.
        WindowGroup("Scratchpad", id: ScratchpadWindow.sceneID) {
            ScratchpadWindow()
        }
    }
}

