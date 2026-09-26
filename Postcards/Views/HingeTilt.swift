//
//  HingeTilt.swift
//  Postcards
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import SwiftUI

/// Tilts the picture side as the device folds: the hinge angle drives an
/// effect, never the layout (Chapter 10). The tilt rises from nothing
/// when flat to a few degrees when the device is partially open, and
/// turns about the axis that faces the fold: the trailing edge in a
/// side-by-side split, the bottom edge in a stacked one.
@available(iOS 27.1, *)
struct HingeTilt: ViewModifier {
    @Environment(\.splitArrangementAxis) private var axis
    @State private var fold = 0.0
    @State private var hasFirstReading = false

    func body(content: Content) -> some View {
        let sideBySide = axis == .horizontal
        content
            .rotation3DEffect(
                .degrees(fold * 18),
                axis: sideBySide ? (x: 0, y: 1, z: 0) : (x: 1, y: 0, z: 0),
                anchor: sideBySide ? .trailing : .bottom,
                perspective: 0.6)
            .onHingeChange { _, context in
                let amount: Double
                if let hinge = context.hinge, hinge.status == .partiallyOpen {
                    // 180° maps to 0, 90° or less to 1.
                    amount = min(max((180 - hinge.angle.degrees) / 90, 0), 1)
                } else {
                    amount = 0
                }
                // The first reading arrives as the view appears: apply it
                // without animation, so a card never drifts into place.
                if hasFirstReading {
                    withAnimation(.smooth(duration: 0.35)) { fold = amount }
                } else {
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) { fold = amount }
                    hasFirstReading = true
                }
            }
    }
}

@available(iOS 27.1, *)
extension View {
    func hingeTilt() -> some View {
        modifier(HingeTilt())
    }
}
