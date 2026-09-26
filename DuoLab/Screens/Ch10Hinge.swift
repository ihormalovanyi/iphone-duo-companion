//
//  Ch10Hinge.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 10: the hinge, for effects and interactions, never layout.
//

import SwiftUI

// iOS 27.1 symbols don't compile for Mac Catalyst in Xcode 27.1 beta
// (185924957); see Chapter 19.
#if !targetEnvironment(macCatalyst)

// snippet:begin ch10-onhingechange
/// The hinge as SwiftUI reports it. A nil hinge means no hinge data
/// (see the chapter's Discrepancy). It never means closed.
@available(iOS 27.1, *)
struct HingeReadout: View {
    @State private var hinge: DeviceHinge?

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16) {
            if let hinge {
                GridRow { Text("Status"); Text(name(of: hinge.status)) }
                GridRow {
                    Text("Degrees")
                    Text(hinge.angle.degrees, format: .number.precision(
                        .fractionLength(1)))
                }
                GridRow {
                    Text("Radians")
                    Text(hinge.angle.radians, format: .number.precision(
                        .fractionLength(3)))
                }
            } else {
                GridRow { Text("Hinge"); Text("nil") }
            }
        }
        .monospacedDigit()
        .onHingeChange { _, newContext in
            hinge = newContext.hinge
        }
    }

    /// `DeviceHinge.Status` is a struct, not an enum: keep a default.
    private func name(of status: DeviceHinge.Status) -> String {
        switch status {
        case .closed: "closed"
        case .partiallyOpen: "partially open"
        case .fullyOpen: "fully open"
        default: "unknown"
        }
    }
}
// snippet:end ch10-onhingechange

@available(iOS 27.1, *)
struct HingeReadoutScreen: View {
    var body: some View {
        VStack(spacing: 24) {
            HingeReadout()
                .font(.title2)
            DemoHint("""
                Fold the simulator with the Device Hub controls. The angle \
                is for effects; for layout, use arrangements and reserved \
                regions.
                """)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// snippet:begin ch10-hinge-effect
/// A parallax-and-blur effect driven by the hinge angle. It reacts only
/// while the device is partially open and resets otherwise, so the
/// effect never sticks. Scale, offset and blur leave the view's layout
/// size unchanged.
struct HingeParallaxCard: View {
    /// 0 while flat or closed, up to 1 at a right angle or less.
    @State private var fold = 0.0

    var body: some View {
        HeroArtwork()
            .scaleEffect(1 + fold * 0.15)
            .offset(y: -fold * 40)
            .blur(radius: fold * 6)
            .clipShape(.rect(cornerRadius: 24))
            .animation(.smooth, value: fold)
            .gated { view in
                if #available(iOS 27.1, *) {
                    view.onHingeChange { _, context in
                        if let hinge = context.hinge,
                           hinge.status == .partiallyOpen {
                            fold = amount(for: hinge.angle)
                        } else {
                            fold = 0
                        }
                    }
                } else {
                    view
                }
            }
    }

    /// Flat (180°) maps to 0; 90° or less maps to 1.
    private func amount(for angle: Angle) -> Double {
        min(max((180 - angle.degrees) / 90, 0), 1)
    }
}
// snippet:end ch10-hinge-effect

struct HingeEffectScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            HingeParallaxCard()
                .frame(maxHeight: 420)
            DemoHint("""
                Fold the device partway: the artwork zooms, lifts and \
                blurs with the angle, and settles back when flat or closed.
                """)
        }
        .padding()
    }
}

#endif
