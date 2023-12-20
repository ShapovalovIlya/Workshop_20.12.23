//
//  CVDSHome.swift
//  BookStore
//
//  Created by Илья Шаповалов on 20.12.2023.
//

import UIKit

final class CVDSHome {
    private let collectionView: UICollectionView
    private lazy var dataSource: DataSource = makeDataSource(collectionView)
    
    init(_ collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.collectionView.dataSource = dataSource
        registerItems()
    }
    
    func update(_ dataModel: DataModel) {
        var snapshot = DataSnapshot()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(
            dataModel.segment.map(Item.segment),
            toSection: .segment
        )
        snapshot.appendItems(
            dataModel.top.map(Item.book),
            toSection: .top
        )
        snapshot.appendItems(
            dataModel.recent.map(Item.book),
            toSection: .recent
        )
        dataSource.supplementaryViewProvider = configureHeaders(dataModel)
        dataSource.apply(snapshot)
    }
}

private extension CVDSHome {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias DataSnapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    func makeDataSource(_ collectionView: UICollectionView) -> DataSource {
        .init(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: item.identifier,
                for: indexPath
            )
            switch item {
            case .segment(let title):
                let cell = cell as? SegmentCell
                cell?.configure(title)
                
            case .book(let model):
                let cell = cell as? TopBooksViewCell
                cell?.configure(
                    title: model.title,
                    author: model.author,
                    imageUrl: model.imageUrl
                )
            }
            return cell
        }
    }
    
    func configureHeaders(_ dataModel: DataModel) -> DataSource.SupplementaryViewProvider {
        { collectionView, kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: Section(rawValue: indexPath.section)?.supplementaryIdentifier ?? "",
                for: indexPath
            ) as? HeaderSupplementaryView
            switch Section(rawValue: indexPath.section) {
            case .top:
                header?.configure(
                    dataModel.topHeader.title,
                    action: dataModel.topHeader.action
                )
            case .recent:
                header?.configure(
                    dataModel.recentHeader.title,
                    action: dataModel.recentHeader.action
                )
            default: break
            }
            return header
        }
    }
    
    func registerItems() {
        collectionView.register(
            TopBooksViewCell.self,
            forCellWithReuseIdentifier: TopBooksViewCell.identifier
        )
        collectionView.register(
            SegmentCell.self,
            forCellWithReuseIdentifier: SegmentCell.identifier
        )
        collectionView.register(
            HeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderSupplementaryView.identifier
        )
    }
}

extension CVDSHome {
    enum Section: Int, CaseIterable {
        case segment
        case top
        case recent
        
        var supplementaryIdentifier: String { HeaderSupplementaryView.identifier }
    }
    
    enum Item: Hashable {
        case segment(String)
        case book(DataModel.Book)
        
        var identifier: String {
            switch self {
            case .segment: SegmentCell.identifier
            case .book: TopBooksViewCell.identifier
            }
        }
    }
    
    struct DataModel {
        let topHeader: Header
        let segment: [String]
        let top: [Book]
        let recentHeader: Header
        let recent: [Book]
        
        struct Header {
            let title: String
            let action: () -> Void
        }
        
        struct Book: Hashable {
            let title: String
            let author: String
            let imageUrl: String
        }
    }
    
}
