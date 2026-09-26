//
//  PoseMatrixUITests.swift
//  DuoLabUITests
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  The iPhone Duo simulator has no command for folding, Split View or
//  Picture in Picture, and synthesized touches may not reach apps on it,
//  so this suite only launches the app, waits for it and takes a
//  screenshot per pose. Put the device (or Device Hub) into a pose by
//  hand, then run the tests with that pose enabled, for example:
//
//    TEST_RUNNER_DUOLAB_POSES=book,laptop xcodebuild test ...
//
//  (xcodebuild passes TEST_RUNNER_-prefixed variables to the test
//  runner without the prefix.)
//

import XCTest

// snippet:begin ch18-uitest-matrix
/// Launches DuoLab once per pose and keeps a screenshot of each. The
/// device's current pose (`.custom`) and right-to-left run every time;
/// the rest need a person to fold or arrange the device first, so they
/// run only when DUOLAB_POSES names them.
final class PoseMatrixUITests: XCTestCase {
    @MainActor
    func testEveryPose() throws {
        let environment = ProcessInfo.processInfo.environment
        let requested = Set(
            (environment["DUOLAB_POSES"] ?? "").split(separator: ",")
                .compactMap { PoseLabel(rawValue: String($0)) }
        )
        for pose in PoseLabel.allCases {
            guard pose.isScriptable || requested.contains(pose) else {
                continue
            }
            if let orientation = pose.deviceOrientation {
                XCUIDevice.shared.orientation = orientation
            }
            let app = XCUIApplication()
            app.launchEnvironment["DUOLAB_POSE"] = pose.rawValue
            app.launchArguments += pose.launchArguments
            app.launch()
            XCTAssertTrue(
                app.wait(for: .runningForeground, timeout: 10),
                "DuoLab did not reach the foreground in \(pose.title)"
            )
            attachScreenshot(of: app, pose: pose)
            app.terminate()
        }
        if requested.isEmpty { throw XCTSkip("No pose selected") }
    }
}

extension PoseLabel {
    /// Poses a test can set up without a person at the device.
    var isScriptable: Bool {
        self == .custom || self == .rtl
    }

    var deviceOrientation: UIDeviceOrientation? {
        switch self {
        case .closedPortrait, .openTall: .portrait
        case .closedLandscape, .openWide: .landscapeLeft
        default: nil
        }
    }

    /// Right-to-left runs the app in Arabic with forced RTL layout.
    var launchArguments: [String] {
        guard self == .rtl else { return [] }
        return [
            "-AppleLanguages", "(ar)",
            "-AppleTextDirection", "YES",
            "-NSForceRightToLeftWritingDirection", "YES",
        ]
    }
}
// snippet:end ch18-uitest-matrix

// snippet:begin ch18-snapshot-helper
extension XCTestCase {
    /// Attaches a screenshot of the app to the test report, named after
    /// the pose, and keeps it even when the test passes.
    @MainActor
    func attachScreenshot(of app: XCUIApplication, pose: PoseLabel) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "pose-\(pose.rawValue)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
// snippet:end ch18-snapshot-helper
