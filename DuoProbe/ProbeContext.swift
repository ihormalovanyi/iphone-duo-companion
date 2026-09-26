//
//  ProbeContext.swift
//  DuoProbe
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  The values both probes read the same way: everything that comes from
//  the window scene, the deprecated main screen, and the hinge.
//

import SwiftUI
import UIKit

/// `UIScreen.main` is deprecated since iOS 26, but measuring what it
/// returns on iPhone Duo is part of the probe's job (Chapter 2). The
/// probe reads it through a protocol requirement so the build stays
/// free of deprecation warnings; apps should not read it at all.
@MainActor
private protocol MainScreenProviding {
    static var main: UIScreen { get }
}

extension UIScreen: MainScreenProviding {}

@MainActor
private var deprecatedMainScreen: UIScreen {
    (UIScreen.self as any MainScreenProviding.Type).main
}

/// The hinge as the log records it, from either framework.
struct HingeValues: Equatable, Sendable {
    var status: String?
    var degrees: Double?
    var radians: Double?
    var isNil: Bool

    static let unavailable = HingeValues(isNil: true)

    @available(iOS 27.1, *)
    init(_ hinge: DeviceHinge?) {
        status = hinge?.status.probeName
        degrees = hinge?.angle.degrees
        radians = hinge?.angle.radians
        isNil = hinge == nil
    }

    @available(iOS 27.1, *)
    @MainActor
    init(_ hinge: UIHinge?) {
        status = hinge?.status.probeName
        radians = hinge.map { Double($0.angle) }
        degrees = radians.map { $0 * 180 / .pi }
        isNil = hinge == nil
    }

    init(isNil: Bool) {
        self.isNil = isNil
    }
}

extension ProbeRecord {
    /// Fills the fields that come from the window scene and the main
    /// screen. Leaves them `nil` when the view is not in a scene yet.
    @MainActor
    mutating func fillScene(_ scene: UIWindowScene?) {
        uiScreenMainBounds = Size(deprecatedMainScreen.bounds.size)
        guard let scene else { return }
        let geometry = scene.effectiveGeometry
        windowSceneScreenBounds = Size(scene.screen.bounds.size)
        effectiveGeometryBounds = Rect(geometry.coordinateSpace.bounds)
        nativeScale = Double(scene.screen.nativeScale)
        interfaceOrientation = geometry.interfaceOrientation.probeName
        userInterfaceIdiom = scene.traitCollection.userInterfaceIdiom
            .probeName
        sceneActivationState = scene.activationState.probeName
    }

    /// Fills the hinge fields. `nil` hinge values mean "no update yet".
    mutating func fillHinge(_ hinge: HingeValues?) {
        guard let hinge else { return }
        hingeStatus = hinge.status
        hingeAngleDegrees = hinge.degrees
        hingeAngleRadians = hinge.radians
        hingeIsNil = hinge.isNil
    }
}

/// The keyboard notifications both probes record.
enum KeyboardNotifications {
    static let names: [Notification.Name] = [
        UIResponder.keyboardWillShowNotification,
        UIResponder.keyboardDidShowNotification,
        UIResponder.keyboardWillHideNotification,
        UIResponder.keyboardDidHideNotification,
        UIResponder.keyboardWillChangeFrameNotification,
        UIResponder.keyboardDidChangeFrameNotification,
    ]

    /// The keyboard's end frame, in screen coordinates.
    static func endFrame(_ notification: Notification) -> CGRect? {
        let key = UIResponder.keyboardFrameEndUserInfoKey
        return (notification.userInfo?[key] as? NSValue)?.cgRectValue
    }
}
