//
//  ProbeRecord+Conversions.swift
//  Shared (DuoLab, DuoLabUIKit, DuoProbe)
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Converts framework geometry types into the plain values of the log.
//

import SwiftUI
import UIKit

extension ProbeRecord.Size {
    init(_ size: CGSize) {
        self.init(w: Double(size.width), h: Double(size.height))
    }
}

extension ProbeRecord.Rect {
    init(_ rect: CGRect) {
        self.init(
            x: Double(rect.minX), y: Double(rect.minY),
            w: Double(rect.width), h: Double(rect.height)
        )
    }
}

extension ProbeRecord.Insets {
    /// SwiftUI insets are already leading/trailing.
    init(_ insets: EdgeInsets) {
        self.init(
            top: Double(insets.top), leading: Double(insets.leading),
            bottom: Double(insets.bottom), trailing: Double(insets.trailing)
        )
    }

    /// UIKit directional insets map one to one.
    init(_ insets: NSDirectionalEdgeInsets) {
        self.init(
            top: Double(insets.top), leading: Double(insets.leading),
            bottom: Double(insets.bottom), trailing: Double(insets.trailing)
        )
    }

    /// UIKit left/right insets, resolved against a layout direction.
    init(
        _ insets: UIEdgeInsets,
        layoutDirection: UIUserInterfaceLayoutDirection
    ) {
        let isRTL = layoutDirection == .rightToLeft
        self.init(
            top: Double(insets.top),
            leading: Double(isRTL ? insets.right : insets.left),
            bottom: Double(insets.bottom),
            trailing: Double(isRTL ? insets.left : insets.right)
        )
    }
}

// iOS 27.1 symbols don't compile for Mac Catalyst in Xcode 27.1 beta
// (185924957), so region conversions are left out of Catalyst builds.
#if !targetEnvironment(macCatalyst)
extension ProbeRecord.Region {
    /// A SwiftUI reserved region, in the coordinate space of the proxy
    /// that returned it.
    @available(iOS 27.1, *)
    init(_ region: ReservedRegion) {
        self.init(
            frame: .init(region.frame),
            margins: .init(region.margins),
            isActive: region.isActive
        )
    }

    /// A UIKit reserved region, in the coordinate space of the view that
    /// returned it. UIKit margins are left/right; they are resolved
    /// against the view's layout direction.
    @available(iOS 27.1, *)
    init(
        _ region: UIView.ReservedRegion,
        layoutDirection: UIUserInterfaceLayoutDirection
    ) {
        self.init(
            frame: .init(region.frame),
            margins: .init(region.margins, layoutDirection: layoutDirection),
            isActive: region.isActive
        )
    }
}
#endif
