//
//  CardDetail.swift
//  Postcards
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import PhotosUI
import SwiftUI

/// One card in every pose. A compact width (the outer display) shows one
/// side at a time and flips between them. A regular width shows both
/// sides in an ArrangementView: side by side in the wide layout and in
/// the book pose, stacked in the tall layout and in the laptop pose, the
/// split aligned with the fold when there is one (Chapter 9).
@available(iOS 27.1, *)
struct CardDetail: View {
    let cardID: Postcard.ID
    @Environment(PostcardStore.self) private var store
    @Environment(\.horizontalSizeClass) private var widthClass
    @State private var showsBack = false
    @State private var photoItem: PhotosPickerItem?
    @State private var isEditing = false
    @AppStorage("blueprint") private var blueprint = false

    private var card: Binding<Postcard> {
        Binding(
            get: { store[cardID] ?? .blank() },
            set: { store.update($0) })
    }

    var body: some View {
        Group {
            if widthClass == .compact {
                FlipCard(card: card, showsBack: showsBack)
                    .padding(16)
            } else {
                ArrangementView {
                    PostcardFront(card: card.wrappedValue)
                        .hingeTilt()
                        .padding(20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } secondary: {
                    PostcardBack(card: card)
                        .padding(20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .arrangementViewStyle(.split)
            }
        }
        .background(PaperBackground())
        .navigationTitle(card.wrappedValue.place)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button("Edit", systemImage: "slider.horizontal.3") {
                    isEditing = true
                }
            }
            ToolbarItem {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label("Photo", systemImage: "photo")
                }
            }
            ToolbarItem {
                Toggle("Blueprint", systemImage: "square.dashed", isOn: $blueprint)
            }
            if widthClass == .compact {
                ToolbarItem {
                    Button(showsBack ? "Picture" : "Message",
                           systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                        withAnimation(.smooth(duration: 0.55)) { showsBack.toggle() }
                    }
                }
            }
        }
        .task(id: photoItem) {
            await loadPhoto()
        }
        .sheet(isPresented: $isEditing) {
            EditCardSheet(card: card)
        }
        .onAppear {
            // Debug launch argument for screenshots: opens the sheet at once.
            if CommandLine.arguments.contains("-edit") { isEditing = true }
        }
    }

    private func loadPhoto() async {
        guard let photoItem,
              let data = try? await photoItem.loadTransferable(type: Data.self),
              let image = UIImage(data: data),
              let jpeg = image.preparingThumbnail(of: CGSize(width: 1200, height: 800))?
                .jpegData(compressionQuality: 0.85) ?? image.jpegData(compressionQuality: 0.8)
        else { return }
        var updated = card.wrappedValue
        updated.photo = jpeg
        store.update(updated)
        self.photoItem = nil
    }
}

/// The compact layout: one side at a time, flipped with a 3D turn. The
/// visible side swaps at the halfway point so text never mirrors.
@available(iOS 27.1, *)
struct FlipCard: View {
    let card: Binding<Postcard>
    let showsBack: Bool

    var body: some View {
        VStack {
            Spacer(minLength: 0)
            Color.clear
                .aspectRatio(3 / 2, contentMode: .fit)
                .modifier(FlipModifier(angle: showsBack ? 180 : 0, card: card))
            Spacer(minLength: 0)
        }
    }
}

@available(iOS 27.1, *)
private struct FlipModifier: ViewModifier, Animatable {
    var angle: Double
    let card: Binding<Postcard>

    nonisolated var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func body(content: Content) -> some View {
        // Past the halfway point the back is shown and the turn continues
        // from -90° to 0°, so the back is never mirrored.
        let turn = angle < 90 ? angle : angle - 180
        content
            .overlay {
                if angle < 90 {
                    PostcardFront(card: card.wrappedValue)
                        .hingeTilt()
                } else {
                    PostcardBack(card: card)
                }
            }
            .rotation3DEffect(.degrees(turn), axis: (x: 0, y: 1, z: 0), perspective: 0.55)
    }
}

/// A warm, matte desk under the cards.
struct PaperBackground: View {
    var body: some View {
        Color(red: 0.925, green: 0.906, blue: 0.867)
            .ignoresSafeArea()
    }
}
