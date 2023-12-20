import UIKit
import SnapKit

final class HomeVC: UIViewController {
    private var choosenSortingMethod: SearchResultVC.SortingMethod = .none
    private let udManager: UserDefaultsManager
    private let homeView: HomeContentView
    private let search: SearchBar
    private let networkManager = NetworkingManager.instance
    
    private lazy var sortMenu: UIMenu = {
        let filterByNewest = UIAction(title: "Sort by Newest", handler: { [weak self] _ in
            self?.choosenSortingMethod = .byNewest
        })
        let filterByOldest = UIAction(title: "Sort by Oldest", handler: { [weak self] _ in
            self?.choosenSortingMethod = .byOldest
        })
        return UIMenu(title: "Sort by", options: .displayInline, children: [filterByNewest, filterByOldest])
    }()
    
    private lazy var dataSource = CVDSHome(homeView.collectionView)
    private lazy var delegate = CVDHome(homeView.collectionView)
    
    private var trendingBooks: [TrendingBooks.Book] = []
    private var selectedSegment: TrendingPeriod = .weekly {
       didSet {
           print("Selected segment changed to \(selectedSegment)")
       }
    }
    
    func buttonPressed(selectedSegment: TrendingPeriod) {
        self.selectedSegment = selectedSegment
        trendingBooks.removeAll()
        fetchTrendingBooks()
    }
    
    //MARK: - init(_:)
    init(
        udManager: UserDefaultsManager,
        homeView: HomeContentView,
        search: SearchBar
    ) {
        self.udManager = udManager
        self.homeView = homeView
        self.search = search
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        view = UIView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        view.addSubviewsTamicOff(homeView,search)
        
        search.searchBar.delegate = self
        search.filterButton.menu = sortMenu
        
        setupConstraints()
        homeView.collectionView.delegate = delegate
        print(udManager.getBook(for: UserDefaultsManager.Keys.recent))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchTrendingBooks()
    }
    
    func update() {
        let mapped = Mapper(books: trendingBooks, segment: selectedSegment)
        dataSource.update(
            .init(
                topHeader: mapped.toTopHeader(tap: seeAllTopBooksTap),
                segment: mapped.toSegments(),
                top: mapped.toTopBooks(),
                recentHeader: mapped.toRecentHeader(tap: seeAllRecentBooksTap),
                recent: []
            )
        )
    }
    
    func seeAllTopBooksTap() {
        
    }
    
    func seeAllRecentBooksTap() {
        
    }
    
    private func fetchTrendingBooks() {
        homeView.showSpinner()
        print("Fetching trending books for period: \(selectedSegment)")
        networkManager.getTrendingBooks(for: selectedSegment) { [weak self] result in
            switch result {
            case .success(let trendingBooks):
                        DispatchQueue.main.async {
                            self?.trendingBooks = trendingBooks.map(\.0)
                            self?.update()
                            self?.homeView.hideSpinner()
                        }
            case .failure(let error):
                print("Ошибка при получении недельной подборки: \(error)")
            }
        }
    }
    

    // MARK: - Private Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }

}

extension HomeVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text, !text.isEmpty {
            let vc = SearchResultVC()
            vc.searchRequest = text
            vc.currentSortingMethod = choosenSortingMethod
            
            searchButtonClicked(withRequest: text, sortingMethod: choosenSortingMethod)
            searchBar.resignFirstResponder()
        } else {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
        searchCancelButtonClicked()
    }
    
}

// MARK: - SearchBarDelegate
private extension HomeVC {
    func searchCancelButtonClicked() {
        self.search.endEditing(true)
        self.search.resignFirstResponder()
    }
    
    func searchButtonClicked(withRequest text: String, sortingMethod: SearchResultVC.SortingMethod) {
        let vc = SearchResultVC()
        vc.searchRequest = text
        vc.currentSortingMethod = sortingMethod
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupConstraints() {
        let offset: CGFloat = 20
        NSLayoutConstraint.activate([
            homeView.topAnchor.constraint(equalTo: search.bottomAnchor, constant: offset),
            homeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            homeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            search.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: offset),
            search.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: offset),
            search.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -offset),
            search.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06),
        ])
    }
}
