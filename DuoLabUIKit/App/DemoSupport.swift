//
//  DemoSupport.swift
//  DuoLabUIKit
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//
//  Small helpers shared by the demo screens. Nothing here is specific to
//  iPhone Duo; the chapter files hold everything the book shows.
//

import UIKit

/// A multi-line, monospaced label for numeric readouts.
final class ReadoutLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        numberOfLines = 0
        font = .monospacedSystemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize,
            weight: .regular
        )
        adjustsFontForContentSizeCategory = true
        textColor = .label
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}

/// A soft diagonal gradient used as stand-in artwork in the demos.
final class GradientArtworkView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    init(colors: [UIColor] = [.systemTeal, .systemIndigo]) {
        super.init(frame: .zero)
        let gradient = layer as? CAGradientLayer
        gradient?.colors = colors.map(\.cgColor)
        gradient?.startPoint = CGPoint(x: 0, y: 0)
        gradient?.endPoint = CGPoint(x: 1, y: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}

/// Shown instead of a demo that needs iOS 27.1 when running on iOS 27.0.
final class RequiresNewerOSViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        var content = UIContentUnavailableConfiguration.empty()
        content.image = UIImage(systemName: "hourglass")
        content.text = "Requires iOS 27.1"
        content.secondaryText = """
            This demo uses APIs introduced for iPhone Duo in iOS 27.1.
            """
        contentUnavailableConfiguration = content
    }
}

extension UIView {
    /// Pins this view's edges to a layout guide.
    func pin(to guide: UILayoutGuide) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            topAnchor.constraint(equalTo: guide.topAnchor),
            bottomAnchor.constraint(equalTo: guide.bottomAnchor),
        ])
    }

    /// Pins this view's edges to another view's edges.
    func pin(to other: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: other.leadingAnchor),
            trailingAnchor.constraint(equalTo: other.trailingAnchor),
            topAnchor.constraint(equalTo: other.topAnchor),
            bottomAnchor.constraint(equalTo: other.bottomAnchor),
        ])
    }
}

extension NSLayoutConstraint {
    /// The constraint with a different priority, for inline activation.
    func prioritized(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

extension CGFloat {
    /// A compact number for readouts: at most one decimal place.
    var readout: String {
        Double(self).formatted(.number.precision(.fractionLength(0...1)))
    }
}

extension UIViewController {
    /// A vertical stack of controls and readouts under the safe area,
    /// inside a scroll view so every demo works in every pose.
    func makeScrollingStack() -> UIStackView {
        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll.pin(to: view)
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        scroll.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        let content = scroll.contentLayoutGuide
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            content.widthAnchor.constraint(
                equalTo: scroll.frameLayoutGuide.widthAnchor
            ),
            stack.topAnchor.constraint(equalTo: content.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
        ])
        return stack
    }

    /// A filled button that runs `action`.
    func makeButton(
        _ title: String,
        action: @escaping @MainActor () -> Void
    ) -> UIButton {
        UIButton(
            configuration: .filled(),
            primaryAction: UIAction(title: title) { _ in action() }
        )
    }
}
