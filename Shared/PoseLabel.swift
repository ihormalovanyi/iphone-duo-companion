//
//  PoseLabel.swift
//  Shared (DuoLab, DuoLabUIKit, DuoProbe)
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

/// The poses the book measures on iPhone Duo. DuoProbe tags every record
/// with one of these labels; the raw value is what lands in the log.
enum PoseLabel: String, CaseIterable, Codable, Identifiable {
    case closedPortrait
    case closedLandscape
    case openTall
    case openWide
    case book
    case laptop
    case tent
    case splitLeft
    case splitRight
    case pipStacked
    case sheetOuter
    case sheetInner
    case rtl
    case reduceTransparency
    case custom

    var id: Self { self }

    /// A short human-readable title for pickers and readouts.
    var title: String {
        switch self {
        case .closedPortrait: "Closed, portrait"
        case .closedLandscape: "Closed, landscape"
        case .openTall: "Open in a tall layout"
        case .openWide: "Open in a wide layout"
        case .book: "Partially folded, like a book"
        case .laptop: "Folded like a laptop"
        case .tent: "Folded like a tent"
        case .splitLeft: "Split View, left app"
        case .splitRight: "Split View, right app"
        case .pipStacked: "Picture in Picture, stacked"
        case .sheetOuter: "Sheet on the outer display"
        case .sheetInner: "Sheet on the inner display"
        case .rtl: "Right-to-left language"
        case .reduceTransparency: "Reduce Transparency on"
        case .custom: "Custom"
        }
    }
}
