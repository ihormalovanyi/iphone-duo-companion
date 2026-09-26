//
//  CardsList.swift
//  Postcards
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI

/// The list of cards beside the selected card. In a compact width the
/// split view collapses to a stack; in a regular width it shows both
/// columns (Chapter 6). The system decides, the code does not.
@available(iOS 27.1, *)
struct CardsSplitView: View {
    @Environment(PostcardStore.self) private var store
    @AppStorage("blueprint") private var blueprint = false
    @State private var selection: Postcard.ID?

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(store.cards) { card in
                    CardRow(card: card)
                }
                .onDelete { offsets in
                    for index in offsets { store.delete(store.cards[index].id) }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Postcards")
            .onAppear {
                // Debug launch argument for screenshots: shows the first card.
                if CommandLine.arguments.contains("-showFirstCard"), selection == nil {
                    selection = store.cards.first?.id
                }
            }
            .toolbar {
                ToolbarItem {
                    Button("New card", systemImage: "square.and.pencil") {
                        selection = store.add().id
                    }
                }
                ToolbarItem {
                    Toggle("Blueprint", systemImage: "square.dashed", isOn: $blueprint)
                        .help("Draws what the system reports over the app: safe area, bar, fold, cameras")
                }
            }
        } detail: {
            if let selection, store[selection] != nil {
                CardDetail(cardID: selection)
            } else {
                ContentUnavailableView(
                    "Pick a postcard",
                    systemImage: "envelope.open",
                    description: Text("Fold, rotate, or open the device with a card on screen."))
            }
        }
    }
}

@available(iOS 27.1, *)
struct CardRow: View {
    let card: Postcard

    var body: some View {
        HStack(spacing: 14) {
            PostcardFront(card: card, compact: true)
                .frame(width: 84)
            VStack(alignment: .leading, spacing: 3) {
                Text(card.place)
                    .font(.headline)
                Text(card.postmark, format: .dateTime.day().month(.wide).year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}
