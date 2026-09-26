//
//  Ch06Containers.swift
//  DuoLabUIKit - Chapter 6
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit

/// Launches the system containers the chapter covers: a split view
/// controller, a tab bar controller that may show a sidebar, and a
/// sheet with a placement picker.
final class ContainersViewController: UIViewController {
    private let placements: [(String, UISheetPresentationController.Placement)] = [
        ("Automatic", .automatic),
        ("Leading", .leading),
        ("Center", .center),
        ("Trailing", .trailing),
    ]
    private lazy var placementPicker = UISegmentedControl(
        items: placements.map(\.0)
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let stack = makeScrollingStack()
        stack.addArrangedSubview(makeButton("Split view controller") {
            [weak self] in
            let split = Self.makeSplitViewController()
            split.modalPresentationStyle = .fullScreen
            self?.present(split, animated: true)
        })
        stack.addArrangedSubview(makeButton("Tabs with a sidebar") {
            [weak self] in
            let tabs = Self.makeTabBarController()
            tabs.modalPresentationStyle = .fullScreen
            self?.present(tabs, animated: true)
        })
        placementPicker.selectedSegmentIndex = 0
        stack.addArrangedSubview(placementPicker)
        stack.addArrangedSubview(makeButton("Present sheet") {
            [weak self] in
            guard let self else { return }
            let index = placementPicker.selectedSegmentIndex
            presentSheet(placement: placements[index].1)
        })
    }

    // snippet:begin ch06-split-view-controller
    /// A two-column split view with a separate stack for compact
    /// widths. The system decides when to collapse it; the app only
    /// provides a view controller for each column.
    static func makeSplitViewController() -> UISplitViewController {
        let split = UISplitViewController(style: .doubleColumn)
        split.preferredDisplayMode = .oneBesideSecondary
        split.setViewController(ItemListViewController(), for: .primary)
        split.setViewController(ItemDetailViewController(), for: .secondary)
        let compact = UINavigationController(
            rootViewController: ItemListViewController()
        )
        split.setViewController(compact, for: .compact)
        return split
    }
    // snippet:end ch06-split-view-controller

    // snippet:begin ch06-tab-sidebar-placement
    /// Tabs that can also appear as a sidebar. The sidebar's preferred
    /// placement asks for the sidebar wherever it is supported; the
    /// default, `.automatic`, shows the tab bar on iOS.
    static func makeTabBarController() -> UITabBarController {
        let tabs = UITabBarController(tabs: [
            UITab(
                title: "Library",
                image: UIImage(systemName: "books.vertical"),
                identifier: "library"
            ) { _ in UINavigationController(
                rootViewController: ItemListViewController()
            ) },
            UITab(
                title: "Search",
                image: UIImage(systemName: "magnifyingglass"),
                identifier: "search"
            ) { _ in UINavigationController(
                rootViewController: ItemDetailViewController()
            ) },
        ])
        tabs.mode = .tabSidebar
        tabs.sidebar.preferredPlacement = .sidebar
        return tabs
    }
    // snippet:end ch06-tab-sidebar-placement

    // snippet:begin ch06-sheet-preferred-placement
    /// Presents a sheet at the requested placement: leading, centered
    /// or trailing in the presenting view. The placement is ignored
    /// when the sheet is anchored to a source view.
    func presentSheet(placement: UISheetPresentationController.Placement) {
        let sheet = UINavigationController(
            rootViewController: ItemDetailViewController()
        )
        if let controller = sheet.sheetPresentationController {
            controller.detents = [.medium(), .large()]
            controller.preferredPlacement = placement
        }
        present(sheet, animated: true)
    }
    // snippet:end ch06-sheet-preferred-placement
}

/// A plain list of items for the container demos.
final class ItemListViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Items"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "item")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { [weak self] _ in
                self?.presentingViewController?.dismiss(animated: true)
            }
        )
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int { 30 }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "item", for: indexPath
        )
        var content = cell.defaultContentConfiguration()
        content.text = "Item \(indexPath.row + 1)"
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let detail = ItemDetailViewController()
        detail.itemNumber = indexPath.row + 1
        showDetailViewController(
            UINavigationController(rootViewController: detail), sender: self
        )
    }
}

/// The detail column, sheet and tab content for the container demos.
final class ItemDetailViewController: UIViewController {
    var itemNumber: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = itemNumber.map { "Item \($0)" } ?? "Detail"
        var content = UIContentUnavailableConfiguration.empty()
        content.text = itemNumber.map { "Item \($0)" } ?? "No selection"
        content.secondaryText = "Resize the window to see the container adapt."
        contentUnavailableConfiguration = content
        if presentingViewController != nil, navigationController?.viewControllers.first === self {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                systemItem: .done,
                primaryAction: UIAction { [weak self] _ in
                    self?.dismiss(animated: true)
                }
            )
        }
    }
}
