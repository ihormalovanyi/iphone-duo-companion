//
//  Ch19Migration.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 19: the one availability gate DuoLab uses everywhere, and
//  the Mac Catalyst guard around iOS 27.1 code.
//

import SwiftUI

// snippet:begin ch19-availability-gate
extension View {
    /// Applies `transform` to the view in place, so one step of a
    /// modifier chain can be gated with `if #available` without
    /// breaking the chain. Availability can't change while the app
    /// runs, so the branch never swaps the view's identity at run time.
    func gated<Gated: View>(
        @ViewBuilder _ transform: (Self) -> Gated
    ) -> Gated {
        transform(self)
    }
}
// snippet:end ch19-availability-gate

// snippet:begin ch19-catalyst-guard
/// Two guards, two jobs. `#if` keeps iOS 27.1 code out of Mac Catalyst
/// builds, which can't compile iOS 27.1 symbols in Xcode 27.1 beta
/// (185924957). `if #available` keeps it off iOS 27.0 at run time.
struct HingeStatusSection: View {
    var body: some View {
        #if !targetEnvironment(macCatalyst)
        if #available(iOS 27.1, *) {
            HingeReadout()
        } else {
            Text("The hinge API needs iOS 27.1.")
        }
        #else
        Text("The hinge API isn't available in Mac Catalyst builds yet.")
        #endif
    }
}
// snippet:end ch19-catalyst-guard

struct AvailabilityGateScreen: View {
    var body: some View {
        Form {
            Section {
                HingeStatusSection()
            } header: {
                Text("Per view: #if and if #available")
            } footer: {
                DemoHint("""
                    A whole view that needs iOS 27.1 is gated once, where \
                    it's used.
                    """)
            }

            Section {
                Text(ProcessInfo.processInfo.operatingSystemVersionString)
                    .font(.callout.monospaced())
            } header: {
                Text("Running on")
            } footer: {
                DemoHint("""
                    One 27.1 modifier on a view that runs on iOS 27.0 is \
                    gated with `gated(_:)`; see the Vertical Bar Opt-Out \
                    and Hinge Effect demos.
                    """)
            }
        }
    }
}
