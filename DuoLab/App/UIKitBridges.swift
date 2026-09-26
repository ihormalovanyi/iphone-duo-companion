//
//  UIKitBridges.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Small UIKit helpers for the readouts that SwiftUI doesn't expose.
//

import SwiftUI
import UIKit

/// Reports the window scene that hosts a SwiftUI view, and reports it
/// again when the view moves to another window.
struct WindowSceneReader: UIViewRepresentable {
    let onChange: (UIWindowScene?) -> Void

    func makeUIView(context: Context) -> SceneTrackingView {
        let view = SceneTrackingView()
        view.onChange = onChange
        return view
    }

    func updateUIView(_ view: SceneTrackingView, context: Context) {
        view.onChange = onChange
    }

    final class SceneTrackingView: UIView {
        var onChange: ((UIWindowScene?) -> Void)?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            let scene = window?.windowScene
            // Report after the current SwiftUI update finishes.
            Task { [weak self] in self?.onChange?(scene) }
        }
    }
}

/// `UIScreen.main` is deprecated. DuoLab reads it in one place only, to
/// show how its bounds differ from the scene's on iPhone Duo. Reading it
/// through a protocol keeps that demonstration free of warnings.
@MainActor
private protocol MainScreenProviding {
    static var main: UIScreen { get }
}

extension UIScreen: MainScreenProviding {}

@MainActor
enum LegacyScreen {
    /// The bounds of `UIScreen.main`, for comparison only. Never use this
    /// value for layout.
    static var mainBounds: CGRect {
        (UIScreen.self as any MainScreenProviding.Type).main.bounds
    }
}
