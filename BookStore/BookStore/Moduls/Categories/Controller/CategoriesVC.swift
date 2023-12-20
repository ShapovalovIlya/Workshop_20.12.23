import UIKit

class CategoriesVC: UIViewController {
    
    //MARK: - CreateUIElements, private constans
    private let categoriesView = CategoriesView()
    var books = [CategoryCollection.Work]()
    private let categoriesName = ["Love", "Fiction", "Horror", "Crime", "Drama", "Classics", "Children", "Sci-fi", "Humor", "Poetry", "History of art design styles", "History", "Biography", "Business"]
    private let category: [String: Categories] = ["Love": .love, "Fiction": .fiction, "Horror": .horror, "Crime": .crime, "Drama": .drama, "Classics": .classics, "Children": .forChildren, "Sci-fi": .sci_fi, "Humor": .humor, "Poetry": .poetry, "History of art design styles": .art, "History": .history, "Biography": .biography, "Business": .business]
    private let imageCategoriesName = ["Rectangle 11-2", "Rectangle 11-3", "Rectangle 11", "Rectangle 12"]
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        categoriesView.collectionView.delegate = self
        categoriesView.collectionView.dataSource = self
        view = categoriesView
        view.backgroundColor = .background
//        categoriesView.searchBar.delegate = self
        navigationController?.navigationBar.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            view.endEditing(true)
        }
        super .touchesBegan(touches, with: event)
    }
    
    //MARK: - PrivateMethods
    private func presentIndicator() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.frame = view.bounds
        activityIndicatorView.center = view.center
        activityIndicatorView.color = .black
        activityIndicatorView.backgroundColor = .clear.withAlphaComponent(0.2)
        view.addSubview(activityIndicatorView)
        return activityIndicatorView
    }
    
    private func getBooksFromNetwork(with category: Categories, categoryString: String) {
        let activityIndicator = presentIndicator()
        activityIndicator.startAnimating()
        NetworkingManager.instance.getCategoryCollection (for: category) { result in
            switch result {
            case .success(let subjectResponse):
                self.books = subjectResponse.first?.works ?? [CategoryCollection.Work]()
                DispatchQueue.main.async {
                    let vc = LikesVC()
                    vc.books = self.books
                    vc.genre = categoryString
                    vc.previosVC = categoryString
                    activityIndicator.stopAnimating()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presentAlertErorNotCategoryList(with: error.localizedDescription)
                    activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    private func presentAlertErorNotCategoryList(with error: String) {
        let alert = UIAlertController(title: "Ошибка при получении категорий: \(error)", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func setImageCategory() -> UIImage {
        let imageString = imageCategoriesName.randomElement()
        return UIImage(named: imageString ?? "Rectangle 11-2") ?? UIImage()
    }
}

//MARK: - extensions CategoriesVC
extension CategoriesVC: UICollectionViewDelegate,
                        UICollectionViewDataSource,
                        UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return categoriesName.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoriesCell.self.description(),
                                                            for: indexPath) as? CategoriesCell
        else {
            return UICollectionViewCell()
        }
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 5
        cell.genre.text = categoriesName[indexPath.item]
        cell.image.image = setImageCategory()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = category[categoriesName[indexPath.item]]
        getBooksFromNetwork(with: category ?? .art,
                            categoryString: categoriesName[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: CategoriesHeader.self.description(),
                                                                           for: indexPath) as? CategoriesHeader
        else {
            return UICollectionReusableView()
        }
        header.headerLabel.text = "Categories"
        header.headerLabel.font = UIFont.openSansRegular(ofSize: 20)
        return header
    }
}

extension CategoriesVC: SearchBarVCDelegate {
    func searchCancelButtonClicked() {
        self.categoriesView.searchBar.endEditing(true)
        self.categoriesView.searchBar.resignFirstResponder()
    }
    
    func searchButtonClicked(withRequest text: String, sortingMethod: SearchResultVC.SortingMethod) {
        let vc = SearchResultVC()
        vc.searchRequest = text
        vc.currentSortingMethod = sortingMethod
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



