//
//  SearchBarVC.swift
//  BookStore
//
//  Created by Anna Zaitsava on 13.12.23.
//

import UIKit

protocol SearchBar: UIView {
    var searchBar: UISearchBar { get }
    var filterButton: UIButton { get }
}

final class SearchBarView: UIView, SearchBar {

    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search title/author/ISBN no"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .label
        searchBar.barTintColor = .clear
        searchBar.layer.cornerRadius = 5
        searchBar.clipsToBounds = true
        searchBar.showsCancelButton = false
        searchBar.searchTextField.textColor = .elements
        searchBar.searchTextField.font = .openSansRegular(ofSize: 14)
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.searchTextField.borderStyle = .none
        searchBar.searchTextField.leftView?.tintColor = .elements
        searchBar.searchTextField.leftViewMode = .always
        return searchBar
    }()
    
    let filterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .label
        button.setImage(UIImage(named: "filter"), for: .normal)
        button.layer.cornerRadius = 5
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviewsTamicOff(searchBar,filterButton)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubviewsTamicOff(searchBar,filterButton)
        setConstraints()
    }

    // MARK: Private Methods
    private func setConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalTo: heightAnchor),
            
            filterButton.topAnchor.constraint(equalTo: topAnchor),
            filterButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 52),
            filterButton.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
}
