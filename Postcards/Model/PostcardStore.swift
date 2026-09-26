//
//  PostcardStore.swift
//  Postcards
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import Foundation
import Observation

/// The cards, saved as JSON in Documents. Sample cards fill a fresh
/// install.
@MainActor
@Observable
final class PostcardStore {
    var cards: [Postcard]

    private let fileURL = URL.documentsDirectory.appending(path: "postcards.json")

    init() {
        if let data = try? Data(contentsOf: fileURL),
           let saved = try? JSONDecoder().decode([Postcard].self, from: data),
           !saved.isEmpty {
            cards = saved
        } else {
            cards = Postcard.samples
        }
    }

    subscript(id: Postcard.ID) -> Postcard? {
        cards.first { $0.id == id }
    }

    func update(_ card: Postcard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index] = card
        save()
    }

    @discardableResult
    func add() -> Postcard {
        let card = Postcard.blank()
        cards.insert(card, at: 0)
        save()
        return card
    }

    func delete(_ id: Postcard.ID) {
        cards.removeAll { $0.id == id }
        save()
    }

    func save() {
        guard let data = try? JSONEncoder().encode(cards) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
