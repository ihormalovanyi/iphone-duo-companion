//
//  Postcard.swift
//  Postcards
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI

/// One postcard: a picture side and a written side.
struct Postcard: Identifiable, Codable, Hashable, Sendable {
    var id = UUID()
    /// The place the card comes from; also the navigation title.
    var place: String
    /// The line above the place on the picture side.
    var greeting = "Greetings from"
    var message: String
    /// Address lines, newline-separated.
    var recipient: String
    /// SF Symbol printed on the stamp.
    var stamp: String
    var postmark: Date
    /// The drawn picture, used unless a photo was picked.
    var art: Art
    /// JPEG data of a picked photo.
    var photo: Data?

    /// Six drawn pictures, flat poster style: a sky, a ground band, a
    /// sun and one symbol.
    enum Art: String, Codable, CaseIterable, Sendable {
        case coast, alps, tram, desert, north, lagoon

        var symbol: String {
            switch self {
            case .coast: "sailboat.fill"
            case .alps: "mountain.2.fill"
            case .tram: "tram.fill"
            case .desert: "sun.max.fill"
            case .north: "moon.stars.fill"
            case .lagoon: "water.waves"
            }
        }

        var sky: Color {
            switch self {
            case .coast: Color(red: 0.914, green: 0.886, blue: 0.816)
            case .alps: Color(red: 0.867, green: 0.906, blue: 0.933)
            case .tram: Color(red: 0.945, green: 0.851, blue: 0.710)
            case .desert: Color(red: 0.957, green: 0.882, blue: 0.757)
            case .north: Color(red: 0.118, green: 0.165, blue: 0.227)
            case .lagoon: Color(red: 0.875, green: 0.941, blue: 0.933)
            }
        }

        var ground: Color {
            switch self {
            case .coast: Color(red: 0.184, green: 0.435, blue: 0.561)
            case .alps: Color(red: 0.243, green: 0.361, blue: 0.310)
            case .tram: Color(red: 0.549, green: 0.231, blue: 0.180)
            case .desert: Color(red: 0.780, green: 0.478, blue: 0.227)
            case .north: Color(red: 0.231, green: 0.298, blue: 0.388)
            case .lagoon: Color(red: 0.227, green: 0.651, blue: 0.627)
            }
        }

        var accent: Color {
            switch self {
            case .coast: Color(red: 0.890, green: 0.604, blue: 0.176)
            case .alps: Color(red: 0.949, green: 0.949, blue: 0.957)
            case .tram: Color(red: 0.969, green: 0.922, blue: 0.835)
            case .desert: Color(red: 0.482, green: 0.176, blue: 0.149)
            case .north: Color(red: 0.624, green: 0.827, blue: 0.780)
            case .lagoon: Color(red: 0.969, green: 0.698, blue: 0.404)
            }
        }

        /// The symbol's color: the sky's ink on light skies, the accent
        /// at night.
        var symbolColor: Color {
            switch self {
            case .north: accent
            case .alps: accent
            default: Color(red: 0.969, green: 0.957, blue: 0.925)
            }
        }
    }
}

extension Postcard {
    /// The cards a fresh install shows, so every pose has something to
    /// draw on first open.
    static let samples: [Postcard] = [
        Postcard(
            place: "Cinque Terre", message: """
                The boats go out at six and the village is still asleep. \
                I had coffee on the harbour wall and thought of you.
                """,
            recipient: "Olena Kovalenko\n12 Yaroslaviv Val\nKyiv 01054",
            stamp: "sailboat.fill", postmark: Date(timeIntervalSince1970: 1_789_680_000),
            art: .coast),
        Postcard(
            place: "Zermatt", message: """
                Snow to the doorstep in September. The train climbs like \
                it has all day. Bring gloves when you come.
                """,
            recipient: "Taras Melnyk\n4 Rue des Alpes\n1201 Genève",
            stamp: "mountain.2.fill", postmark: Date(timeIntervalSince1970: 1_789_070_000),
            art: .alps),
        Postcard(
            place: "Lisbon", message: """
                Tram 28 again, standing room only, and the driver sang. \
                The tiles here are every blue there is.
                """,
            recipient: "Maria Santos\n88 Rua Garrett\n1200-204 Lisboa",
            stamp: "tram.fill", postmark: Date(timeIntervalSince1970: 1_788_460_000),
            art: .tram),
        Postcard(
            place: "Marrakech", message: """
                The square fills at dusk with smoke and drums. I bought a \
                lamp I have no room for. Worth it.
                """,
            recipient: "Amina El Fassi\n5 Derb Dabachi\n40000 Marrakech",
            stamp: "sun.max.fill", postmark: Date(timeIntervalSince1970: 1_787_850_000),
            art: .desert),
        Postcard(
            place: "Tromsø", message: """
                Green light over the fjord at two in the morning. Nobody \
                spoke. Then everyone did, at once.
                """,
            recipient: "Ingrid Haugen\n17 Storgata\n9008 Tromsø",
            stamp: "moon.stars.fill", postmark: Date(timeIntervalSince1970: 1_787_240_000),
            art: .north),
        Postcard(
            place: "Bora Bora", message: """
                The water is the colour of the postcard, which I did not \
                believe until now. Back on the 30th.
                """,
            recipient: "Hiro Tanaka\n2-11-3 Meguro\nTokyo 153-0063",
            stamp: "water.waves", postmark: Date(timeIntervalSince1970: 1_786_630_000),
            art: .lagoon),
    ]

    /// A blank card to write on.
    static func blank() -> Postcard {
        Postcard(place: "Somewhere", message: "",
                 recipient: "Name\nStreet\nCity",
                 stamp: "airplane", postmark: .now, art: .coast)
    }
}
