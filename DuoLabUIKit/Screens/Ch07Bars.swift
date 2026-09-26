//
//  Ch07Bars.swift
//  DuoLabUIKit - Chapter 7
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit

/// A task-oriented screen with a full set of bar items: axis behaviors,
/// visibility priorities, the system overflow menu, a compression
/// preference, and a floating button that follows the vertical bar's
/// edge. "Open player" pushes a screen that opts out of vertical bars.
final class BarsViewController: UIViewController {
    private let readout = ReadoutLabel()
    private let floatingButton = UIButton(configuration: .filled())
    private var floatingLeading: NSLayoutConstraint?
    private var floatingTrailing: NSLayoutConstraint?

    private lazy var composeItem = UIBarButtonItem(
        title: "Compose",
        image: UIImage(systemName: "square.and.pencil"),
        primaryAction: UIAction { [weak self] _ in self?.note("Compose") }
    )
    private lazy var archiveItem = UIBarButtonItem(
        title: "Archive",
        image: UIImage(systemName: "archivebox"),
        primaryAction: UIAction { [weak self] _ in self?.note("Archive") }
    )
    private lazy var shareItem = UIBarButtonItem(
        title: "Share",
        image: UIImage(systemName: "square.and.arrow.up"),
        primaryAction: UIAction { [weak self] _ in self?.note("Share") }
    )
    private var isSelecting = false
    private lazy var selectItem = UIBarButtonItem(
        title: "Select",
        image: UIImage(systemName: "checkmark.circle"),
        primaryAction: UIAction { [weak self] _ in
            self?.toggleSelecting()
        }
    )
    private lazy var statusItem = UIBarButtonItem(customView: SyncStatusView())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItems = [composeItem, shareItem]
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItems = [selectItem, statusItem]
        toolbarItems = [
            archiveItem,
            .flexibleSpace(),
            UIBarButtonItem(
                title: "Flag",
                image: UIImage(systemName: "flag"),
                primaryAction: UIAction { [weak self] _ in self?.note("Flag") }
            ),
        ]
        configureAxisBehaviors()
        configureOverflow()
        preferBarItems()

        let stack = makeScrollingStack()
        stack.addArrangedSubview(readout)
        stack.addArrangedSubview(makeButton("Open player") { [weak self] in
            self?.show(PlayerViewController(), sender: self)
        })
        addFloatingButton()
        observeVerticalBarEdge()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: animated)
    }

    private func note(_ action: String) {
        readout.text = "Tapped \(action)"
    }

    /// Select is a symbol; while selecting, the item becomes the text
    /// Done, like Edit/Done, so it has to stay in the horizontal bar.
    private func toggleSelecting() {
        note(isSelecting ? "Done" : "Select")
        isSelecting.toggle()
        selectItem.title = isSelecting ? "Done" : "Select"
        selectItem.image = isSelecting
            ? nil : UIImage(systemName: "checkmark.circle")
    }

    // snippet:begin ch07-uikit-axis-behavior
    /// An item that switches between a symbol and text, like Select and
    /// Done, stays horizontal, and a compact custom view opts in to
    /// vertical bars. Symbol items need nothing: the automatic behavior
    /// already allows both axes.
    private func configureAxisBehaviors() {
        guard #available(iOS 27.1, *) else { return }
        selectItem.axisBehavior = .horizontalOnly
        statusItem.axisBehavior = .verticalPreferred
    }
    // snippet:end ch07-uikit-axis-behavior

    // snippet:begin ch07-uikit-overflow
    /// Compose stays visible longest and Archive overflows first. The
    /// actions of the old custom "More" menu join the system overflow
    /// menu instead of competing with it.
    private func configureOverflow() {
        composeItem.visibilityPriority = .high
        archiveItem.visibilityPriority = .low
        navigationItem.additionalOverflowItems = UIDeferredMenuElement
            .uncached { completion in
                completion([
                    UIAction(title: "Export as PDF") { _ in },
                    UIAction(title: "Print") { _ in },
                ])
            }
    }
    // snippet:end ch07-uikit-overflow

    // snippet:begin ch07-uikit-compression
    /// A task-oriented screen: when its bar items and the tab bar share
    /// the vertical bar and run out of room, the tab bar compresses
    /// first and the items stay.
    private func preferBarItems() {
        guard #available(iOS 27.1, *) else { return }
        navigationItem.verticalBarCompressionBehavior = .prefersBarItems
    }
    // snippet:end ch07-uikit-compression

    // snippet:begin ch07-vertical-bar-edge-trait
    /// Keeps a floating button on the same side as the vertical bar,
    /// so the screen's controls stay together. The trait reports the
    /// preferred edge even while no vertical bar is visible.
    private func observeVerticalBarEdge() {
        guard #available(iOS 27.1, *) else { return }
        updateFloatingButton()
        registerForTraitChanges(
            UITraitCollection.systemTraitsAffectingVerticalBarEdge
        ) { (self: Self, _: UITraitCollection) in
            self.updateFloatingButton()
        }
    }

    @available(iOS 27.1, *)
    private func updateFloatingButton() {
        let edge = traitCollection.verticalBarEdge
        floatingLeading?.isActive = edge == .leading
        floatingTrailing?.isActive = edge != .leading
        readout.text = switch edge {
        case .leading: "Vertical bar edge: leading"
        case .trailing: "Vertical bar edge: trailing"
        case .unspecified: "No vertical bar in this context"
        @unknown default: "Vertical bar edge: unknown"
        }
    }
    // snippet:end ch07-vertical-bar-edge-trait

    private func addFloatingButton() {
        floatingButton.configuration?.image = UIImage(systemName: "plus")
        floatingButton.configuration?.cornerStyle = .capsule
        floatingButton.accessibilityLabel = "Add"
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingButton)
        let margins = view.layoutMarginsGuide
        let safe = view.safeAreaLayoutGuide
        floatingLeading = floatingButton.leadingAnchor.constraint(
            equalTo: margins.leadingAnchor
        )
        floatingTrailing = floatingButton.trailingAnchor.constraint(
            equalTo: margins.trailingAnchor
        )
        floatingTrailing?.isActive = true
        floatingButton.bottomAnchor.constraint(
            equalTo: safe.bottomAnchor, constant: -16
        ).isActive = true
    }
}

/// A compact custom bar view: one 28 pt status symbol, narrow enough for
/// the vertical bar's fixed width.
final class SyncStatusView: UIView {
    private let symbol = UIImageView(
        image: UIImage(systemName: "checkmark.circle")
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        symbol.translatesAutoresizingMaskIntoConstraints = false
        symbol.contentMode = .scaleAspectFit
        addSubview(symbol)
        symbol.pin(to: self)
        isAccessibilityElement = true
        accessibilityLabel = "Synced"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 28, height: 28)
    }
}

// snippet:begin ch07-preferred-vertical-bar-behavior
/// A full-screen player whose controls work best in horizontal bars.
/// The choice is stable, so the override returns a constant. The
/// navigation and tab bar controllers forward the question to their
/// top and selected children, so no container code is needed.
final class PlayerViewController: UIViewController {
    @available(iOS 27.1, *)
    override var preferredVerticalBarBehavior: UIVerticalBarBehavior {
        .disabled
    }
}
// snippet:end ch07-preferred-vertical-bar-behavior

extension PlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Player"
        view.backgroundColor = .black
        let artwork = GradientArtworkView(colors: [.systemPink, .systemOrange])
        view.addSubview(artwork)
        artwork.pin(to: view.safeAreaLayoutGuide)
        toolbarItems = [
            UIBarButtonItem(
                title: "Back 15 seconds",
                image: UIImage(systemName: "gobackward.15"),
                primaryAction: nil
            ),
            .flexibleSpace(),
            UIBarButtonItem(
                title: "Play",
                image: UIImage(systemName: "play.fill"),
                primaryAction: nil
            ),
            .flexibleSpace(),
            UIBarButtonItem(
                title: "Forward 15 seconds",
                image: UIImage(systemName: "goforward.15"),
                primaryAction: nil
            ),
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
    }
}
