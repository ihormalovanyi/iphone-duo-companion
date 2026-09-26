//
//  PostcardFront.swift
//  Postcards
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI

/// The picture side: a photo when one was picked, otherwise the drawn
/// picture, with the greeting printed along the bottom.
struct PostcardFront: View {
    let card: Postcard
    var compact = false

    var body: some View {
        Color.clear
            .aspectRatio(3 / 2, contentMode: .fit)
            .overlay {
                if let data = card.photo, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    DrawnPicture(art: card.art)
                }
            }
            .overlay(alignment: .bottomLeading) {
                if !compact {
                    caption
                }
            }
            .clipShape(.rect(cornerRadius: compact ? 4 : 12))
            .overlay {
                RoundedRectangle(cornerRadius: compact ? 4 : 12)
                    .strokeBorder(.white.opacity(0.7), lineWidth: compact ? 1 : 3)
            }
            .shadow(color: .black.opacity(compact ? 0.12 : 0.22), radius: compact ? 2 : 14, y: compact ? 1 : 8)
    }

    private var caption: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(card.greeting.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(2)
                .foregroundStyle(.black.opacity(0.55))
            Text(card.place)
                .font(.system(.title, design: .serif).weight(.bold).italic())
                .foregroundStyle(.black.opacity(0.85))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(red: 0.98, green: 0.965, blue: 0.93).opacity(0.92), in: .rect(cornerRadius: 8))
        .padding(14)
    }
}

/// A flat poster: sky, a ground band, a sun and one symbol.
struct DrawnPicture: View {
    let art: Postcard.Art

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            ZStack(alignment: .topLeading) {
                art.sky
                Circle()
                    .fill(art.accent)
                    .frame(width: h * 0.34)
                    .position(x: w * 0.74, y: h * 0.3)
                Rectangle()
                    .fill(art.ground)
                    .frame(height: h * 0.42)
                    .position(x: w / 2, y: h - h * 0.21)
                Image(systemName: art.symbol)
                    .font(.system(size: h * 0.36, weight: .regular))
                    .foregroundStyle(art.symbolColor)
                    .position(x: w * 0.3, y: h * 0.6)
            }
        }
    }
}
