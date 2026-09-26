//
//  PostcardBack.swift
//  Postcards
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI

/// The written side: message on the left, address and stamp on the
/// right. The stamp sits in the top trailing corner unless the camera's
/// active occlusion region is there; then it moves below the region
/// (Chapter 8). The frame of a region includes its margins.
@available(iOS 27.1, *)
struct PostcardBack: View {
    @Binding var card: Postcard

    var body: some View {
        Color.clear
            .aspectRatio(3 / 2, contentMode: .fit)
            .overlay {
                GeometryReader { proxy in
                    let occlusions = proxy.reservedRegions(kind: .occlusion)
                        .filter(\.isActive)
                        .map(\.frame)
                    ZStack(alignment: .topTrailing) {
                        paper
                        HStack(alignment: .top, spacing: 0) {
                            messageColumn
                            Rectangle()
                                .fill(.black.opacity(0.18))
                                .frame(width: 1)
                                .padding(.vertical, 18)
                            addressColumn
                        }
                        Stamp(symbol: card.stamp, date: card.postmark)
                            .padding(14)
                            .offset(y: stampDrop(avoiding: occlusions, in: proxy.size))
                    }
                }
            }
            .clipShape(.rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.black.opacity(0.08), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.18), radius: 12, y: 6)
    }

    private var paper: some View {
        Color(red: 0.98, green: 0.965, blue: 0.93)
    }

    private var messageColumn: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(card.postmark, format: .dateTime.day().month(.wide))
                .font(.system(.caption, design: .serif).italic())
                .foregroundStyle(.secondary)
            TextEditor(text: $card.message)
                .font(.system(.body, design: .serif))
                .scrollContentBackground(.hidden)
                .lineSpacing(3)
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var addressColumn: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer(minLength: 0)
            ForEach(Array(card.recipient.split(separator: "\n").enumerated()), id: \.offset) { _, line in
                VStack(alignment: .leading, spacing: 4) {
                    Text(line)
                        .font(.system(.callout, design: .serif))
                    Rectangle()
                        .fill(.black.opacity(0.25))
                        .frame(height: 1)
                }
            }
        }
        .padding(18)
        .padding(.top, 84)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }

    /// How far the stamp moves down so it never sits under the camera.
    private func stampDrop(avoiding occlusions: [CGRect], in cardSize: CGSize) -> CGFloat {
        Self.stampDrop(cardSize: cardSize, stamp: CGSize(width: 76, height: 92),
                       inset: 14, occlusions: occlusions)
    }
}

@available(iOS 27.1, *)
extension PostcardBack {
    /// Pure geometry, kept separate so it can be tested: given the card's
    /// size, the stamp's default frame and the active occlusions, return
    /// the vertical drop that clears every overlapping region.
    static func stampDrop(cardSize: CGSize, stamp: CGSize, inset: CGFloat, occlusions: [CGRect]) -> CGFloat {
        let frame = CGRect(x: cardSize.width - inset - stamp.width, y: inset,
                           width: stamp.width, height: stamp.height)
        let overlapping = occlusions.filter { $0.intersects(frame) }
        guard let lowest = overlapping.map(\.maxY).max() else { return 0 }
        return max(0, lowest + 8 - frame.minY)
    }
}

/// A stamp with a perforated edge and a postmark.
struct Stamp: View {
    let symbol: String
    let date: Date

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 26, weight: .regular))
                    .foregroundStyle(Color(red: 0.98, green: 0.965, blue: 0.93))
                    .frame(width: 48, height: 40)
                    .background(Color(red: 0.184, green: 0.435, blue: 0.561), in: .rect(cornerRadius: 2))
                Text("iPHONE DUO · 27.1")
                    .font(.system(size: 6.5, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.black.opacity(0.6))
            }
            .padding(8)
            .background(.white, in: .rect(cornerRadius: 2))
            .overlay {
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [2.5, 2.5]))
                    .foregroundStyle(Color(red: 0.98, green: 0.965, blue: 0.93))
            }
            Postmark(date: date)
                .offset(x: -30, y: 14)
        }
        .frame(width: 76, height: 92, alignment: .topTrailing)
    }
}

struct Postmark: View {
    let date: Date

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.black.opacity(0.35), lineWidth: 1.2)
            VStack(spacing: 1) {
                Text(date, format: .dateTime.day().month(.abbreviated))
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                Text(date, format: .dateTime.year())
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
            }
            .foregroundStyle(.black.opacity(0.5))
        }
        .frame(width: 44, height: 44)
        .rotationEffect(.degrees(-12))
    }
}
