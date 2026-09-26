//
//  Ch15Games.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 15: games and video fill every pose.
//

import MetalKit
import SpriteKit
import SwiftUI

// MARK: - Metal

// snippet:begin ch15-metal-drawable-resize
/// Hosts an MTKView whose drawable follows the view's size, so every
/// fold, rotation and Split View resize renders at the new size instead
/// of stretching the old frame.
struct MetalCanvas: UIViewRepresentable {
    let renderer: Renderer

    func makeUIView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: renderer.queue?.device)
        view.autoResizeDrawable = true  // The default, and the point.
        view.clearColor = MTLClearColor(red: 0.1, green: 0.2, blue: 0.4,
                                        alpha: 1)
        view.delegate = renderer
        return view
    }

    func updateUIView(_ view: MTKView, context: Context) {}
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Rebuild size-dependent resources here, once per resize,
        // never once per frame.
        drawableSize = size
    }
}
// snippet:end ch15-metal-drawable-resize

/// Clears the drawable each frame; the size it records is what the
/// Games screen shows.
@MainActor @Observable
final class Renderer: NSObject {
    @ObservationIgnored
    let queue = MTLCreateSystemDefaultDevice()?.makeCommandQueue()
    fileprivate(set) var drawableSize = CGSize.zero

    func draw(in view: MTKView) {
        guard let pass = view.currentRenderPassDescriptor,
              let drawable = view.currentDrawable,
              let commands = queue?.makeCommandBuffer(),
              let encoder = commands.makeRenderCommandEncoder(
                  descriptor: pass)
        else { return }
        encoder.endEncoding()
        commands.present(drawable)
        commands.commit()
    }
}

struct MetalScreen: View {
    @State private var renderer = Renderer()

    var body: some View {
        MetalCanvas(renderer: renderer)
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                Text("Drawable: \(Int(renderer.drawableSize.width)) × "
                     + "\(Int(renderer.drawableSize.height)) px")
                    .font(.callout.monospacedDigit())
                    .padding(10)
                    .background(.regularMaterial, in: .capsule)
                    .padding()
            }
    }
}

// MARK: - SpriteKit

// snippet:begin ch15-spritekit-scale-mode
/// A SpriteKit scene in SwiftUI with a choice of scale mode.
/// `.resizeFill` resizes the scene with the view, so the game fills
/// every pose; the other modes scale a fixed-size scene: aspect-fill
/// crops, aspect-fit adds bars, fill stretches each axis.
struct SpriteKitStage: View {
    @State private var scene = OrbitScene(size: CGSize(width: 400,
                                                      height: 600))
    @State private var scaleMode = SKSceneScaleMode.resizeFill

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .onChange(of: scaleMode, initial: true) {
                scene.scaleMode = scaleMode
            }
            .toolbar {
                Picker("Scale Mode", selection: $scaleMode) {
                    Text("Resize Fill").tag(SKSceneScaleMode.resizeFill)
                    Text("Aspect Fill").tag(SKSceneScaleMode.aspectFill)
                    Text("Aspect Fit").tag(SKSceneScaleMode.aspectFit)
                    Text("Fill").tag(SKSceneScaleMode.fill)
                }
            }
    }
}

/// Keeps its content centered whatever size the scene gets.
final class OrbitScene: SKScene {
    private let sun = SKShapeNode(circleOfRadius: 40)

    override func didMove(to view: SKView) {
        backgroundColor = .black
        sun.fillColor = .orange
        addChild(sun)
        layoutNodes()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutNodes()
    }

    private func layoutNodes() {
        sun.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
}
// snippet:end ch15-spritekit-scale-mode

struct SpriteKitScreen: View {
    var body: some View {
        SpriteKitStage()
    }
}

// MARK: - Letterbox math

// snippet:begin ch15-letterbox-math
/// Fits content with a fixed aspect ratio (width / height) into a
/// container and reports the bars it leaves: letterbox bars above and
/// below, pillarbox bars at the sides. Prefer changing the aspect
/// ratio; if padding can't be avoided, fill the bars with artwork.
struct AspectFit: Equatable {
    let content: CGRect
    /// Height of each bar above and below the content.
    let letterbox: CGFloat
    /// Width of each bar beside the content.
    let pillarbox: CGFloat

    init(aspectRatio: CGFloat, in container: CGSize) {
        let width = min(container.width, container.height * aspectRatio)
        let height = width / aspectRatio
        pillarbox = (container.width - width) / 2
        letterbox = (container.height - height) / 2
        content = CGRect(x: pillarbox, y: letterbox,
                         width: width, height: height)
    }

    /// The share of the container the bars cover, from 0 to 1.
    func barShare(of container: CGSize) -> CGFloat {
        let used = content.width * content.height
        return 1 - used / (container.width * container.height)
    }
}
// snippet:end ch15-letterbox-math

struct LetterboxScreen: View {
    @State private var sceneSize = CGSize.zero
    @State private var ratio = 16.0 / 9.0

    /// Point sizes of the displays, as measured in the iPhone Duo
    /// simulator (outer 466 × 678, inner 669 × 951, in portrait).
    private let references = [
        DisplayReference(name: "Outer display", width: 466, height: 678),
        DisplayReference(name: "Inner display", width: 669, height: 951),
        DisplayReference(name: "Inner, landscape", width: 951, height: 669),
    ]

    var body: some View {
        Form {
            Picker("Game aspect ratio", selection: $ratio) {
                Text("16:9").tag(16.0 / 9.0)
                Text("4:3").tag(4.0 / 3.0)
                Text("9:16").tag(9.0 / 16.0)
            }
            .pickerStyle(.segmented)

            Section("This scene, live") {
                row("\(DuoFormat.size(sceneSize))", container: sceneSize)
            }

            Section {
                ForEach(references) { reference in
                    row(reference.name, container: reference.size)
                }
            } header: {
                Text("Derived")
            } footer: {
                DemoHint("""
                    Computed from the point sizes, not measured on \
                    hardware. The inner display is about 1.42:1, so \
                    16:9 content leaves bars in either orientation.
                    """)
            }
        }
        .onSceneSizeChange { sceneSize = $0 }
    }

    private func row(_ title: String, container: CGSize) -> some View {
        let fit = AspectFit(aspectRatio: ratio, in: container)
        return VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
            Text("Content " + DuoFormat.size(fit.content.size))
            Text("Letterbox " + DuoFormat.points(fit.letterbox)
                 + " · Pillarbox " + DuoFormat.points(fit.pillarbox))
            Text("Bars cover "
                 + Double(fit.barShare(of: container))
                    .formatted(.percent.precision(.fractionLength(0))))
        }
        .font(.callout.monospacedDigit())
    }
}

struct DisplayReference: Identifiable {
    let name: String
    let size: CGSize

    var id: String { name }

    init(name: String, width: CGFloat, height: CGFloat) {
        self.name = name
        self.size = CGSize(width: width, height: height)
    }
}
