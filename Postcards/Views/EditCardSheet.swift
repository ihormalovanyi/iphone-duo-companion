//
//  EditCardSheet.swift
//  Postcards
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI

/// The details of a card in a sheet. Closed, it comes up half height and
/// can be pulled to full height; on the inner display the system presents
/// it as a form sheet and keeps it clear of the fold (Chapters 11, 12).
struct EditCardSheet: View {
    @Binding var card: Postcard
    @Environment(\.dismiss) private var dismiss

    private let stamps = ["airplane", "bicycle", "camera.fill", "envelope.fill",
                          "globe.europe.africa.fill", "sun.max.fill", "leaf.fill",
                          "sailboat.fill", "mountain.2.fill", "tram.fill",
                          "moon.stars.fill", "water.waves"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Front") {
                    TextField("Place", text: $card.place)
                    TextField("Greeting", text: $card.greeting)
                    Picker("Picture", selection: $card.art) {
                        ForEach(Postcard.Art.allCases, id: \.self) { art in
                            Label {
                                Text(String(describing: art).capitalized)
                            } icon: {
                                Image(systemName: art.symbol)
                            }
                            .tag(art)
                        }
                    }
                    if card.photo != nil {
                        Button("Remove photo", role: .destructive) {
                            card.photo = nil
                        }
                    }
                }
                Section("Back") {
                    Picker("Stamp", selection: $card.stamp) {
                        ForEach(stamps, id: \.self) { symbol in
                            Image(systemName: symbol).tag(symbol)
                        }
                    }
                    DatePicker("Postmark", selection: $card.postmark, displayedComponents: .date)
                    TextField("Recipient", text: $card.recipient, axis: .vertical)
                        .lineLimit(3...4)
                }
            }
            .navigationTitle("Edit card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
