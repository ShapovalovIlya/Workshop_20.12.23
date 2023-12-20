import UIKit
import SnapKit

protocol HomeContentView: UIView {
    var collectionView: UICollectionView { get }
    
    func showSpinner()
    func hideSpinner()
}

final class HomeView: UIView, HomeContentView {
    
    //MARK: UI Elements
    let collectionView: UICollectionView = {
        let layout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .background
        collectionView.bounces = false
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    let spinnerView: UIActivityIndicatorView = {
        let spinnerView = UIActivityIndicatorView(style: .large)
        spinnerView.color = .black
        spinnerView.isHidden = true
        return spinnerView
    }()
    
    // MARK: - Set Views
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .background
        collectionView.collectionViewLayout = makeLayout()
        addSubview(collectionView)
        addSubview(spinnerView)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func showSpinner() {
        spinnerView.startAnimating()
        spinnerView.isHidden = false
    }
    
    func hideSpinner() {
        spinnerView.isHidden = true
        spinnerView.stopAnimating()
    }
    
}

private extension HomeView {
    func setConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        spinnerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [self] section, env in
            let header = makeHeader()
            switch section {
            case 0:
                return makeSegmentSection(supplementaryItems: [header])
            case 1:
                return makeBooksSection(supplementaryItems: [])
            case 2:
                return makeBooksSection(supplementaryItems: [header])
            default: return nil
            }
        }
    }
    
    func makeSegmentSection(supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem]) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.3),
            heightDimension: .fractionalHeight(1)
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(50)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = supplementaryItems
        return section
    }
    
    func makeBooksSection(supplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem]) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.33),
            heightDimension: .fractionalHeight(1)
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(0.3)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = supplementaryItems
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
        return section
    }
    
    func makeHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(50)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}

extension UIStackView {
    convenience init(spacing: CGFloat, axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment) {
        self.init()
        self.spacing = spacing
        self.axis = axis
        self.alignment = alignment
    }
}
