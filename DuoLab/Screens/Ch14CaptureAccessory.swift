//
//  Ch14CaptureAccessory.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 14: a teleprompter on the outer display while the camera
//  runs on the inner one. Presentation needs a device; the simulator
//  shows the accessory content inline so its layout can be checked.
//

import SwiftUI
import UIKit

// Scene accessories are unavailable in Mac Catalyst, and iOS 27.1
// symbols don't compile for it in Xcode 27.1 beta (185924957).
#if !targetEnvironment(macCatalyst)

// snippet:begin ch14-accessory-model
/// The one model the camera screen and its accessory share. The
/// accessory only presents it; capture state never lives there, because
/// the system can withdraw the accessory at any time.
@MainActor @Observable
final class TeleprompterModel {
    var script = """
        iPhone Duo. One app, two displays, every pose. Read this from \
        the outer display while the inner display runs the camera.
        """
    var fontSize = 34.0
    /// Bound to the accessory's enable toggle; on by default.
    var isEnabled = true
    /// Whether the system can present the accessory right now.
    var isAvailable = false
}
// snippet:end ch14-accessory-model

// snippet:begin ch14-scene-accessory
/// Registers the teleprompter on the view that shows the capture
/// interface. The system presents it on the outer display only while
/// this view is on screen, the device is open, the app is in the
/// foreground and a capture session runs.
@available(iOS 27.1, *)
struct TeleprompterCameraScreen: View {
    @State private var teleprompter = TeleprompterModel()

    var body: some View {
        CameraScreen()
            .sceneAccessory {
                CameraCaptureAccessory(isEnabled: $teleprompter.isEnabled) {
                    TeleprompterView(model: teleprompter)
                }
                .onAvailabilityChange { isAvailable in
                    teleprompter.isAvailable = isAvailable
                }
            }
            .toolbar {
                if teleprompter.isAvailable {
                    Toggle("Teleprompter", systemImage: "text.viewfinder",
                           isOn: $teleprompter.isEnabled)
                }
            }
    }
}
// snippet:end ch14-scene-accessory

/// The accessory content. It checks the role of the scene it runs in,
/// so the same view can say whether it's on the outer display or just
/// being previewed inside the app.
@available(iOS 27.1, *)
struct TeleprompterView: View {
    let model: TeleprompterModel
    @State private var isAccessory = false

    var body: some View {
        ScrollView {
            Text(model.script)
                .font(.system(size: model.fontSize, weight: .semibold))
                .padding()
        }
        .foregroundStyle(.white)
        .background(.black)
        .overlay(alignment: .topTrailing) {
            if !isAccessory {
                Text("Preview")
                    .font(.caption.bold())
                    .padding(6)
                    .background(.yellow, in: .capsule)
                    .foregroundStyle(.black)
                    .padding(8)
            }
        }
        .background {
            WindowSceneReader { scene in
                // The system assigns this role; apps never set it.
                isAccessory = scene?.session.role
                    == .windowCameraCaptureAccessory
            }
            .frame(width: 0, height: 0)
        }
    }
}

/// The demo screen: the capture screen with its accessory and, below
/// it, the accessory content inline, which also works in the simulator.
@available(iOS 27.1, *)
struct CaptureAccessoryScreen: View {
    @State private var preview = TeleprompterModel()

    var body: some View {
        VStack(spacing: 0) {
            TeleprompterCameraScreen()
            TeleprompterView(model: preview)
                .frame(height: 160)
        }
    }
}

#endif
