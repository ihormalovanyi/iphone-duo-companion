//
//  Ch02SceneGeometry.swift
//  DuoLabUIKit - Chapter 2
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit
import os

/// Shows the scene's size, its screen and its scale, all read from the
/// view's context. Resize the scene (open, close, rotate, Split View)
/// and the readout follows.
final class SceneGeometryViewController: UIViewController {
    private let readout = ReadoutLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let stack = makeScrollingStack()
        stack.addArrangedSubview(readout)
    }

    // snippet:begin ch02-uiscreen-replacement
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        readout.text = geometryDescription()
    }

    /// Reads the size, the screen and the scale from this view's
    /// context, the view's own bounds first. `UIScreen.main` is
    /// deprecated since iOS 26; its header points to the scene's
    /// screen and to the trait collection.
    func geometryDescription() -> String {
        // Before: UIScreen.main.bounds and UIScreen.main.scale.
        guard let scene = view.window?.windowScene else {
            return "Not in a window yet"
        }
        let own = view.bounds
        let bounds = scene.effectiveGeometry.coordinateSpace.bounds
        let screen = scene.screen.bounds
        let scale = traitCollection.displayScale
        return """
            View: \(own.width.formatted()) x \(own.height.formatted())
            Scene: \(bounds.width.formatted()) x \(bounds.height.formatted())
            Screen: \(screen.width.formatted()) x \(screen.height.formatted())
            Scale: \(scale.formatted())x
            """
    }
    // snippet:end ch02-uiscreen-replacement
}

// snippet:begin ch02-effective-geometry
extension SceneDelegate {
    private static let logger = Logger(
        subsystem: "pro.ihor.unfolded.DuoLabUIKit", category: "scene"
    )

    /// Called when the scene's effective geometry changes, and always
    /// when the scene moves between screens. Read the new values from
    /// the scene; the parameter holds the previous ones.
    func windowScene(
        _ windowScene: UIWindowScene,
        didUpdateEffectiveGeometry previous: UIWindowScene.Geometry
    ) {
        let geometry = windowScene.effectiveGeometry
        let size = geometry.coordinateSpace.bounds.size
        Self.logger.info("""
            Scene \(Double(size.width)) x \(Double(size.height)) pt, \
            landscape: \(geometry.interfaceOrientation.isLandscape), \
            resizing: \(geometry.isInteractivelyResizing)
            """)
    }
}
// snippet:end ch02-effective-geometry
