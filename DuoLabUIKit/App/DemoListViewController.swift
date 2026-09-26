//
//  DemoListViewController.swift
//  DuoLabUIKit
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit

/// One row per demo screen, grouped by chapter.
struct Demo {
    let chapter: Int
    let title: String
    let make: @MainActor () -> UIViewController
}

extension Demo {
    /// Every UIKit demo in the book, in chapter order. Screens that need
    /// iOS 27.1 show a short explanation on iOS 27.0.
    @MainActor static let all: [Demo] = [
        Demo(chapter: 2, title: "Scene geometry") {
            SceneGeometryViewController()
        },
        Demo(chapter: 4, title: "Fluid grid") {
            FluidGridViewController()
        },
        Demo(chapter: 5, title: "Safe areas, margins, corners") {
            SafeAreasViewController()
        },
        Demo(chapter: 6, title: "System containers") {
            ContainersViewController()
        },
        Demo(chapter: 7, title: "Vertical bars") {
            BarsViewController()
        },
        Demo(chapter: 8, title: "Reserved regions") {
            if #available(iOS 27.1, *) {
                ReservedRegionsViewController()
            } else {
                RequiresNewerOSViewController()
            }
        },
        Demo(chapter: 9, title: "Arrangements") {
            if #available(iOS 27.1, *) {
                ArrangementDemoViewController()
            } else {
                RequiresNewerOSViewController()
            }
        },
        Demo(chapter: 10, title: "Hinge") {
            if #available(iOS 27.1, *) {
                HingeViewController()
            } else {
                RequiresNewerOSViewController()
            }
        },
        Demo(chapter: 12, title: "Windows") {
            WindowsViewController()
        },
        Demo(chapter: 14, title: "Camera capture accessory") {
            CaptureViewController()
        },
        Demo(chapter: 17, title: "Reduce Transparency") {
            ReduceTransparencyViewController()
        },
    ]
}

final class DemoListViewController: UITableViewController {
    private let demos = Demo.all
    private var chapters: [Int] {
        Array(Set(demos.map(\.chapter))).sorted()
    }

    init() {
        super.init(style: .insetGrouped)
        title = "DuoLab UIKit"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "demo")
    }

    /// Scripted runs can open one demo at launch, because synthesized
    /// taps may not reach apps on the iPhone Duo simulator:
    /// `SIMCTL_CHILD_DUOLAB_DEMO=<chapter> xcrun simctl launch ...`
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didOpenLaunchDemo else { return }
        didOpenLaunchDemo = true
        let environment = ProcessInfo.processInfo.environment
        guard let chapter = environment["DUOLAB_DEMO"].flatMap(Int.init),
              let demo = demos.first(where: { $0.chapter == chapter })
        else { return }
        let controller = demo.make()
        if controller.title == nil { controller.title = demo.title }
        show(controller, sender: self)
    }

    private var didOpenLaunchDemo = false

    private func demos(inSection section: Int) -> [Demo] {
        demos.filter { $0.chapter == chapters[section] }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        chapters.count
    }

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        "Chapter \(chapters[section])"
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        demos(inSection: section).count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "demo", for: indexPath
        )
        var content = cell.defaultContentConfiguration()
        content.text = demos(inSection: indexPath.section)[indexPath.row].title
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let demo = demos(inSection: indexPath.section)[indexPath.row]
        let controller = demo.make()
        if controller.title == nil { controller.title = demo.title }
        show(controller, sender: self)
    }
}
