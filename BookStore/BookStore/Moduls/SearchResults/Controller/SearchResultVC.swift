//
//  SearchResultVC.swift
//  BookStore
//
//  Created by Anna Zaitsava on 5.12.23.
//

import UIKit

protocol SearchBarVCDelegate: AnyObject {
    func searchButtonClicked(withRequest text: String, sortingMethod: SearchResultVC.SortingMethod)
    func searchCancelButtonClicked()
}

class SearchResultVC: UIViewController {

    private var udManager = UserDefaultsManager()
    
    enum SortingMethod {
        case none
        case byNewest
        case byOldest
    }
    // MARK: Properties
    
    //массив для получения запроса с сервера
    var booksArray = [Doc]()
    var currentSortingMethod: SortingMethod = .none
    var url = [URL]()
    
    //MARK: - UI Elements

    var searchRequest = "Love"
    var numberOfBooks = 0
    var baseSearchPlaceholder =  "Search title/author/ISBN no"
    
    var searchBar = SearchBarView()
    
    private lazy var numberOfResultsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = ""
        label.font = .openSansBold(ofSize: 20)
        label.textColor = .elements
        return label
        
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(SearchCell.self, forCellWithReuseIdentifier: SearchCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .background
        return collectionView
    }()
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        searchBar.searchBar.delegate = self
        searchBar.searchBar.text = searchRequest
        performSearchRequest()
        setupUI()
        self.navigationController?.navigationBar.tintColor = .elements
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            view.endEditing(true)
        }
        super .touchesBegan(touches, with: event)
    }
    
    // MARK: - Private Methods
    private func performSearchRequest() {
        NetworkingManager.instance.searchBooks(keyword: searchRequest) {
            print("hello")
        } searchCompletion: { object in
            self.booksArray = object.docs
            self.sorting()
            //            print(self.booksArray)
            DispatchQueue.main.async {
                self.numberOfBooks = self.booksArray.count
                self.updateNumberOfResultsLabel(withCount: self.numberOfBooks)
                self.collectionView.reloadData()
            }
        }
    }
    
    private func updateNumberOfResultsLabel(withCount count: Int) {
        numberOfResultsLabel.text = "\(count) Search Results"
    }
    
    private func sorting() {
        switch currentSortingMethod {
        case .byNewest:
            booksArray.sort { ($0.first_publish_year ?? Int.min) > ($1.first_publish_year ?? Int.min) }
            print ("по убыванию")
        case .byOldest:
            booksArray.sort { ($0.first_publish_year ?? Int.max) < ($1.first_publish_year ?? Int.max) }
            print ("по возрастанию")
        case .none:
            break
        }
        collectionView.reloadData()
    }
    
    private func sortByNewest() {
        currentSortingMethod = .byNewest
        print (currentSortingMethod)
        sorting()
    }
    
    private func sortByOldest() {
        currentSortingMethod = .byOldest
        sorting()
        print (currentSortingMethod)
    }
    
    private func setupUI() {
        view.addSubviewsTamicOff(searchBar, numberOfResultsLabel,collectionView)
        
        let offset: CGFloat = 20
        
        NSLayoutConstraint.activate([
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: offset),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: offset),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -offset),
            searchBar.heightAnchor.constraint(equalToConstant: 56),
            
            numberOfResultsLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: offset),
            numberOfResultsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: offset),
            numberOfResultsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -offset),
            
            collectionView.topAnchor.constraint(equalTo: numberOfResultsLabel.bottomAnchor, constant: offset),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: offset),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -offset),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
    }
}


//MARK: - Extensions
extension SearchResultVC: UISearchBarDelegate {
    
}

extension SearchResultVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return booksArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCell.identifier, for: indexPath) as! SearchCell
        
        guard indexPath.item < booksArray.count else { return cell }
        cell.configure(with:  booksArray[indexPath.item])
        
        return cell
    }
}

extension SearchResultVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - 18) / 2
        let cellHeight: CGFloat = 213
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print ("tap cell")
        let vc = BookDetailsViewController()
        let booksModel = BookDetailsModel(key: self.booksArray[indexPath.item].key ?? "",
                                          image: UIImage(),
                                          title: self.booksArray[indexPath.item].title_suggest ?? "Unknowed Name",
                                          authorName: self.booksArray[indexPath.item].author_name?[0] ?? "",
                                          hasFullText: self.booksArray[indexPath.item].has_fulltext ?? false,
                                          ia: self.booksArray[indexPath.item].ia?[0] ?? "" ,
                                          category: self.booksArray[indexPath.item].subject_key?[0] ?? "", raiting: 0.00,
                                          descriptionText: "")
        //!!!: - Затянуть рейтинг и описание книги
        
        //добавление книги в recent
        udManager.addToRecent(booksModel.key)
        print(udManager.getBook(for: UserDefaultsManager.Keys.recent))

        vc.book = booksModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchResultVC: SearchBarVCDelegate {
    func searchCancelButtonClicked() {
        self.searchBar.resignFirstResponder()
    }
    
    func searchButtonClicked(withRequest text: String, sortingMethod: SortingMethod) {
        searchRequest = text
        currentSortingMethod = sortingMethod
        performSearchRequest()
    }
    
}



