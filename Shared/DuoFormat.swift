//
//  DuoFormat.swift
//  Shared (DuoLab, DuoLabUIKit, DuoProbe)
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import CoreGraphics

/// Formats geometry for on-screen readouts, in points.
enum DuoFormat {
    /// `84 pt`, `83.5 pt`.
    static func points(_ value: CGFloat) -> String {
        "\(number(value)) pt"
    }

    /// `669 × 951 pt`.
    static func size(_ size: CGSize) -> String {
        "\(number(size.width)) × \(number(size.height)) pt"
    }

    /// `(0, 402) 669 × 40 pt`.
    static func rect(_ rect: CGRect) -> String {
        "(\(number(rect.minX)), \(number(rect.minY))) "
            + size(rect.size)
    }

    /// `T 0 · L 0 · B 20 · Tr 84`, in reading order.
    static func insets(
        top: CGFloat, leading: CGFloat, bottom: CGFloat, trailing: CGFloat
    ) -> String {
        "T \(number(top)) · L \(number(leading)) · "
            + "B \(number(bottom)) · Tr \(number(trailing))"
    }

    /// Up to one fractional digit, no trailing zero.
    static func number(_ value: CGFloat) -> String {
        Double(value).formatted(.number.precision(.fractionLength(0...1)))
    }
}
