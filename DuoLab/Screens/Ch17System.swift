//
//  Ch17System.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 17: biometry copy and the accessibility settings that change
//  how an app looks on iPhone Duo.
//

import LocalAuthentication
import SwiftUI

// MARK: - Biometry

// snippet:begin ch17-biometry-copy
/// Names the biometry this device has. iPhone Duo has Touch ID in the
/// side button and no Face ID, so copy that hard-codes Face ID is
/// wrong on it.
func unlockButtonTitle() -> String {
    let context = LAContext()
    // biometryType is set only after canEvaluatePolicy(_:error:) runs,
    // whatever it returns.
    var error: NSError?
    _ = context.canEvaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics, error: &error)

    switch context.biometryType {
    case .touchID: return "Unlock with Touch ID"
    case .faceID: return "Unlock with Face ID"
    case .opticID: return "Unlock with Optic ID"
    case .none: return "Unlock"
    @unknown default: return "Unlock"
    }
}
// snippet:end ch17-biometry-copy

struct BiometryScreen: View {
    @State private var title = unlockButtonTitle()

    var body: some View {
        Form {
            Section {
                Button(title, systemImage: "lock.open") {}
            } footer: {
                DemoHint("""
                    In the simulator, turn on Features > Touch ID > \
                    Enrolled to match the device.
                    """)
            }
        }
        .onAppear { title = unlockButtonTitle() }
    }
}

// MARK: - Accessibility

// snippet:begin ch17-accessibility-readout
/// The settings to test every pose with. With Reduce Transparency on, a
/// vertical bar gets a background, so custom content in the bar has to
/// stay legible both ways.
struct AccessibilityReadout: View {
    @Environment(\.accessibilityReduceTransparency)
    private var reducesTransparency
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.legibilityWeight) private var legibilityWeight
    @Environment(\.layoutDirection) private var layoutDirection

    var body: some View {
        Form {
            LabeledContent("Reduce Transparency",
                           value: reducesTransparency ? "On" : "Off")
            LabeledContent("Dynamic Type",
                           value: String(describing: dynamicTypeSize))
            LabeledContent("Accessibility size",
                           value: dynamicTypeSize.isAccessibilitySize
                               ? "Yes" : "No")
            LabeledContent("Bold Text",
                           value: legibilityWeight == .bold ? "On" : "Off")
            LabeledContent("Layout direction",
                           value: String(describing: layoutDirection))
        }
    }
}
// snippet:end ch17-accessibility-readout

struct AccessibilityScreen: View {
    var body: some View {
        AccessibilityReadout()
            .safeAreaInset(edge: .bottom) {
                DemoHint("""
                    Change these in Settings > Accessibility, or with the \
                    Environment Overrides in Xcode. To test right-to-left, \
                    run the scheme with a right-to-left App Language.
                    """)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.bar)
            }
    }
}
