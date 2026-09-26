//
//  Ch04FluidLayout.swift
//  DuoLabUIKit - Chapter 4
//
//  Copyright (c) 2026 Ihor Malovanyi. MIT License.
//

import UIKit

/// A header that switches axis by size class and a grid whose column
/// count follows the width, even-numbered whenever there is a fold.
final class FluidGridViewController: UIViewController {
    private let header = UIStackView()
    private let summary = ReadoutLabel()
    private lazy var collectionView = UICollectionView(
        frame: .zero, collectionViewLayout: makeGridLayout()
    )
    private let cellRegistration = UICollectionView.CellRegistration<
        UICollectionViewListCell, Int
    > { cell, _, number in
        var content = UIListContentConfiguration.cell()
        content.text = "\(number + 1)"
        content.textProperties.alignment = .center
        cell.contentConfiguration = content
        var background = UIBackgroundConfiguration.listCell()
        background.backgroundColor = .secondarySystemBackground
        background.cornerRadius = 12
        cell.backgroundConfiguration = background
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        buildHeader()
        buildGrid()
        observeSizeClasses()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = collectionView.bounds.width
        summary.text = """
            Width \(width.readout) pt, fold: \(hasFold ? "yes" : "no")
            """
    }

    // snippet:begin ch04-trait-tracking
    /// Re-lays the header out whenever a size class changes. The
    /// decision uses size classes only: never the idiom, never the
    /// orientation, never a cached screen size.
    private func observeSizeClasses() {
        updateHeaderAxis()
        registerForTraitChanges([
            UITraitHorizontalSizeClass.self,
            UITraitVerticalSizeClass.self,
        ]) { (self: Self, _: UITraitCollection) in
            self.updateHeaderAxis()
        }
    }

    private func updateHeaderAxis() {
        let traits = traitCollection
        let isWide = traits.horizontalSizeClass == .regular
            || traits.verticalSizeClass == .compact
        header.axis = isWide ? .horizontal : .vertical
    }
    // snippet:end ch04-trait-tracking

    // snippet:begin ch04-compositional-even-columns
    /// A grid whose column count follows the available width, rounded
    /// up to an even number whenever the display has a fold, whether
    /// the device is folded or flat.
    private func makeGridLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] _, environment in
            let width = environment.container.effectiveContentSize.width
            var columns = max(1, Int(width / 180))
            if self?.hasFold == true, !columns.isMultiple(of: 2) {
                columns += 1
            }
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1 / CGFloat(columns)),
                heightDimension: .fractionalHeight(1)
            ))
            item.contentInsets = .init(
                top: 4, leading: 4, bottom: 4, trailing: 4
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(104)
                ),
                repeatingSubitem: item,
                count: columns
            )
            return NSCollectionLayoutSection(group: group)
        }
    }

    /// True when a division region crosses the grid, active or not.
    private var hasFold: Bool {
        guard #available(iOS 27.1, *) else { return false }
        return !collectionView.reservedRegions(
            kind: .division, options: .includeInactive
        ).isEmpty
    }
    // snippet:end ch04-compositional-even-columns

    private func buildHeader() {
        let title = UILabel()
        title.text = "Fluid layout"
        title.font = .preferredFont(forTextStyle: .title2)
        title.adjustsFontForContentSizeCategory = true
        header.addArrangedSubview(title)
        header.addArrangedSubview(summary)
        header.spacing = 8
        header.alignment = .leading
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: margins.topAnchor),
            header.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
        ])
    }

    private func buildGrid() {
        let registration = cellRegistration
        let dataSource = UICollectionViewDiffableDataSource<Int, Int>(
            collectionView: collectionView
        ) { collectionView, indexPath, number in
            collectionView.dequeueConfiguredReusableCell(
                using: registration, for: indexPath, item: number
            )
        }
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])
        snapshot.appendItems(Array(0..<24))
        dataSource.apply(snapshot)
        self.dataSource = dataSource

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: header.bottomAnchor, constant: 16
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: margins.leadingAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: margins.trailingAnchor
            ),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private var dataSource: UICollectionViewDiffableDataSource<Int, Int>?
}
