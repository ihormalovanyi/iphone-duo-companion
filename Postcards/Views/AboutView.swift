//
//  AboutView.swift
//  Postcards
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("""
                        Postcards is the showcase app of *Developing for \
                        iPhone Duo: Approaches and Tips*. A postcard folds, \
                        so the fold of the device becomes the crease of the \
                        card. Open, fold and rotate the device with a card \
                        on screen.
                        """)
                }
                Section("Blueprint") {
                    Text("""
                        The dashed-square toggle draws what the system reports \
                        over the screen: safe area, bar, fold, cameras. The \
                        cards lay out around these lines.
                        """)
                }
                Section("What to try") {
                    row("Closed", "The list gets the system's vertical tab bar; a card flips between its two sides.")
                    row("Open, tall", "Both sides stack; the split view shows the list and the card together.")
                    row("Open, wide", "The picture and the written side sit side by side.")
                    row("Folded like a book", "The spread splits at the fold; the stamp keeps clear of the camera.")
                    row("Folded like a laptop", "Picture on top, message and keyboard below.")
                    row("While folding", "The picture tilts with the hinge angle.")
                    row("Edit", "A sheet: half height when closed, a form sheet when open, clear of the fold.")
                }
                Section("Where it is in the book") {
                    row("Chapters 4 and 6", "Size classes, NavigationSplitView and TabView.")
                    row("Chapter 7", "Vertical bars and toolbarVerticalEdge.")
                    row("Chapter 8", "Reserved regions: the stamp and the Blueprint lines.")
                    row("Chapter 9", "ArrangementView with the split style.")
                    row("Chapter 10", "onHingeChange for the tilt and the readout.")
                    row("Chapter 17", "The keyboard in the laptop pose.")
                }
            }
            .navigationTitle("About")
        }
    }

    private func row(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.headline)
            Text(detail).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
