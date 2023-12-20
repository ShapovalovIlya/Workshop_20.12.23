//
//  CVDHome.swift
//  BookStore
//
//  Created by Илья Шаповалов on 21.12.2023.
//

import UIKit

final class CVDHome: NSObject {
    private struct Drawing {
        static let headerHeight: CGFloat = 50
        static let bookCellHeight: CGFloat = 300
        static let segmentHeight: CGFloat = 20
    }
    
    private let collectionView: UICollectionView
    
    init(_ collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        self.collectionView.delegate = self
    }
}

extension CVDHome: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        switch Section(rawValue: indexPath.section) {
        case .segments:
            return CGSize(
                width: collectionView.frame.width * 0.3,
                height: Drawing.segmentHeight
            )
            
        case .top, .recent:
            return CGSize(
                width: collectionView.frame.width * 0.3,
                height: Drawing.bookCellHeight
            )
            
        default: return .zero
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(
            width: collectionView.frame.width,
            height: Drawing.headerHeight
        )
    }
    
    
}

private extension CVDHome {
    enum Section: Int {
        case segments
        case top
        case recent
    }
}
