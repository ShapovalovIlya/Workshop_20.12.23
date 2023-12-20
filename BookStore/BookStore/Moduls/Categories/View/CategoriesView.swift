import UIKit
import SnapKit

class CategoriesView: UIView {
    
    //MARK: - Create UIElements
    var collectionView: UICollectionView!
    var searchBar = SearchBarView()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCollectionView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private Methods
    private func configureCollectionView() {
        let collectionViewLayout = UICollectionViewLayout()
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: collectionViewLayout)
        collectionView.register(CategoriesCell.self,
                                forCellWithReuseIdentifier: CategoriesCell.self.description())
        collectionView.register(CategoriesHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CategoriesHeader.self.description())
        collectionView.collectionViewLayout = createLayout()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .background
        addSubview(searchBar)
        addSubview(collectionView)
    }
    
    private func setConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(13)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(56)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout(section: createSection())
    }
    
    private func createSection() -> NSCollectionLayoutSection {
        
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(190),
                                                            heightDimension: .absolute(140)))
        item.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(140))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: item,
                                                       count: 2)
        let section = NSCollectionLayoutSection(group: group)
        let header = createHeaderItem()
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        .init(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                heightDimension: .estimated(32)),
              elementKind: UICollectionView.elementKindSectionHeader,
              alignment: .topLeading)
    }
}

