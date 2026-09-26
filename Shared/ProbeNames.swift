//
//  ProbeNames.swift
//  Shared (DuoLab, DuoLabUIKit, DuoProbe)
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Stable, lowercase names for the values DuoLab shows on screen and
//  DuoProbe writes to its log. One spelling per value, in every target.
//

import SwiftUI
import UIKit

extension UserInterfaceSizeClass {
    var probeName: String {
        switch self {
        case .compact: "compact"
        case .regular: "regular"
        @unknown default: "unknown"
        }
    }
}

extension UIUserInterfaceSizeClass {
    /// `nil` for `.unspecified`, so the log records `null`.
    var probeName: String? {
        switch self {
        case .compact: "compact"
        case .regular: "regular"
        case .unspecified: nil
        @unknown default: "unknown"
        }
    }
}

extension UIInterfaceOrientation {
    /// `nil` for `.unknown`, so the log records `null`.
    var probeName: String? {
        switch self {
        case .portrait: "portrait"
        case .portraitUpsideDown: "portraitUpsideDown"
        case .landscapeLeft: "landscapeLeft"
        case .landscapeRight: "landscapeRight"
        case .unknown: nil
        @unknown default: "unknown"
        }
    }
}

extension UIUserInterfaceIdiom {
    var probeName: String {
        switch self {
        case .phone: "phone"
        case .pad: "pad"
        case .mac: "mac"
        case .tv: "tv"
        case .carPlay: "carPlay"
        case .vision: "vision"
        case .unspecified: "unspecified"
        @unknown default: "unknown"
        }
    }
}

extension UIScene.ActivationState {
    var probeName: String {
        switch self {
        case .unattached: "unattached"
        case .foregroundActive: "foregroundActive"
        case .foregroundInactive: "foregroundInactive"
        case .background: "background"
        @unknown default: "unknown"
        }
    }
}

extension ScenePhase {
    var probeName: String {
        switch self {
        case .active: "active"
        case .inactive: "inactive"
        case .background: "background"
        @unknown default: "unknown"
        }
    }
}

extension LayoutDirection {
    var probeName: String {
        switch self {
        case .leftToRight: "leftToRight"
        case .rightToLeft: "rightToLeft"
        @unknown default: "unknown"
        }
    }
}

extension UIUserInterfaceLayoutDirection {
    var probeName: String {
        switch self {
        case .leftToRight: "leftToRight"
        case .rightToLeft: "rightToLeft"
        @unknown default: "unknown"
        }
    }
}

extension HorizontalEdge {
    var probeName: String {
        switch self {
        case .leading: "leading"
        case .trailing: "trailing"
        }
    }
}

// iOS 27.1 symbols don't compile for Mac Catalyst in Xcode 27.1 beta
// (185924957), so their names are left out of Catalyst builds.
#if !targetEnvironment(macCatalyst)
@available(iOS 27.1, *)
extension UIVerticalBarEdge {
    var probeName: String {
        switch self {
        case .unspecified: "unspecified"
        case .leading: "leading"
        case .trailing: "trailing"
        @unknown default: "unknown"
        }
    }
}

@available(iOS 27.1, *)
extension DeviceHinge.Status {
    var probeName: String {
        switch self {
        case .closed: "closed"
        case .partiallyOpen: "partiallyOpen"
        case .fullyOpen: "fullyOpen"
        default: "unknown"
        }
    }
}

@available(iOS 27.1, *)
extension UIHinge.Status {
    var probeName: String {
        switch self {
        case .unknown: "unknown"
        case .closed: "closed"
        case .partiallyOpen: "partiallyOpen"
        case .fullyOpen: "fullyOpen"
        @unknown default: "unknown"
        }
    }
}
#endif
