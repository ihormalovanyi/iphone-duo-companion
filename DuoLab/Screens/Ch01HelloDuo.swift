//
//  Ch01HelloDuo.swift
//  DuoLab
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Chapter 1: the values that drive layout, in one readout.
//

import SwiftUI

// iOS 27.1 symbols don't compile for Mac Catalyst in Xcode 27.1 beta
// (185924957); see Chapter 19.
#if !targetEnvironment(macCatalyst)

// snippet:begin ch01-size-class-readout
/// Shows the values that drive layout on iPhone Duo. Open, close and
/// rotate the device and watch them change.
@available(iOS 27.1, *)
struct SizeClassReadout: View {
    @Environment(\.horizontalSizeClass) private var widthClass
    @Environment(\.verticalSizeClass) private var heightClass
    @Environment(\.displayScale) private var displayScale
    @Environment(\.toolbarVerticalEdge) private var barEdge
    @State private var sceneSize = CGSize.zero

    var body: some View {
        Form {
            LabeledContent("Width class", value: name(of: widthClass))
            LabeledContent("Height class", value: name(of: heightClass))
            LabeledContent("Scene size", value: sizeText)
            LabeledContent("Display scale", value: "\(displayScale)x")
            LabeledContent("Vertical bar edge", value: edgeText)
        }
        .background {
            // A reader that ignores the safe area spans the whole scene,
            // so the view inside it measures the scene, not the form.
            GeometryReader { _ in
                Color.clear
                    .onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { size in
                        sceneSize = size
                    }
            }
            .ignoresSafeArea()
        }
    }

    private var sizeText: String {
        "\(Int(sceneSize.width)) × \(Int(sceneSize.height)) pt"
    }

    private var edgeText: String {
        barEdge.map { String(describing: $0) } ?? "none"
    }

    private func name(of sizeClass: UserInterfaceSizeClass?) -> String {
        sizeClass.map { String(describing: $0) } ?? "unspecified"
    }
}
// snippet:end ch01-size-class-readout

#endif
