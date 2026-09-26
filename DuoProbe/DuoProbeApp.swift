//
//  DuoProbeApp.swift
//  DuoProbe
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  DuoProbe is the instrument behind the book's measured numbers. Pick
//  the pose you are holding the device in, use the app, and share
//  Documents/probe.jsonl: one JSON line per layout pass, hinge update,
//  scene activation change, keyboard notification and manual record.
//
//  Synthesized taps may not reach apps on the iPhone Duo simulator, so a
//  scripted run can set things up through the launch environment
//  (`SIMCTL_CHILD_` variables with `xcrun simctl launch`):
//    DUOPROBE_POSE=<PoseLabel raw value>   preselects the pose
//    DUOPROBE_TAB=uikit                    opens the UIKit probe
//    DUOPROBE_FOCUS_KEYBOARD=1             focuses the text field
//

import SwiftUI

@main
struct DuoProbeApp: App {
    @State private var log = ProbeLog()

    var body: some Scene {
        WindowGroup {
            ProbeRootView()
                .environment(log)
        }
    }
}

/// Two tabs: the SwiftUI probe (with the pose picker, "Record now" and
/// "Share log") and the UIKit probe, which measures the same values
/// through UIKit's APIs.
struct ProbeRootView: View {
    enum Tab: Hashable { case swiftUI, uiKit }

    @State private var selection = LaunchOptions.opensUIKitTab
        ? Tab.uiKit : Tab.swiftUI

    var body: some View {
        TabView(selection: $selection) {
            SwiftUI.Tab("SwiftUI", systemImage: "ruler", value: .swiftUI) {
                SwiftUIProbeView(isActive: selection == .swiftUI)
            }
            SwiftUI.Tab("UIKit", systemImage: "hammer", value: .uiKit) {
                UIKitProbeView()
                    .ignoresSafeArea()
            }
        }
    }
}

/// The launch-environment switches described at the top of this file.
enum LaunchOptions {
    private static var environment: [String: String] {
        ProcessInfo.processInfo.environment
    }

    static var pose: PoseLabel? {
        environment["DUOPROBE_POSE"].flatMap(PoseLabel.init(rawValue:))
    }

    static var opensUIKitTab: Bool {
        environment["DUOPROBE_TAB"] == "uikit"
    }

    static var focusesKeyboard: Bool {
        environment["DUOPROBE_FOCUS_KEYBOARD"] == "1"
    }
}
