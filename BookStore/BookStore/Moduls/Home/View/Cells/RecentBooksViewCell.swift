//
//  RecentBooksViewCell.swift
//  BookStore
//
//  Created by Сазонов Станислав on 05.12.2023.
//

import UIKit

final class RecentBooksViewCell: UICollectionViewCell {
    static let identifier = RecentBooksViewCell.debugDescription()
    
    //MARK: UI Elements
    
    private let recentBooksImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let footerView: UIView = {
        let element = UIView()
        
        element.backgroundColor = .black
        element.layer.cornerRadius = 8
        element.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return element
    }()
    
    private let textStackView = UIStackView(spacing: 10, axis: .vertical, alignment: .leading)
    
    private let bookGenreLabel = UILabel.makeLabel(
        text: "Classic",
        font: .openSansRegular(ofSize: 11),
        textColor: .white
    )
    private let bookTitleLabel = UILabel.makeLabel(
        text: "Top Books",
        font: .openSansRegular(ofSize: 15),
        textColor: .white
    )
    private let bookAuthorLabel = UILabel.makeLabel(
        text: "Top Books",
        font: .openSansRegular(ofSize: 11),
        textColor: .white
    )
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Set Views
    
    private func setupView() {
        backgroundColor = .lightGray
        addSubview(recentBooksImageView)
        addSubview(footerView)
        footerView.addSubview(textStackView)
        textStackView.addArrangedSubview(bookGenreLabel)
        textStackView.addArrangedSubview(bookTitleLabel)
        textStackView.addArrangedSubview(bookAuthorLabel)
        
        layer.cornerRadius = 8
        
    }
    
    // MARK: - Cell Configure
    
    func configureCell(work: (work: CategoryCollection.Work, image: UIImage?)) {
        
      bookTitleLabel.text = work.work.title ?? "No title"
      if let author = work.work.authors.first {
          bookAuthorLabel.text = author.name ?? "No author"
      } else {
          bookAuthorLabel.text = "No author"
      }
      recentBooksImageView.image = work.image
    }
    
//    func configure(title: String, )
    
    // MARK: - Setup Constraints
    
    private func setConstraints() {
        
        recentBooksImageView.snp.makeConstraints { make in
            make.width.equalTo(121)
            make.height.equalTo(171)
            make.top.equalTo(20)
            make.centerX.equalToSuperview()
        }
        
        footerView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            
            make.height.equalTo(60)
            
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            
        }
        
        textStackView.snp.makeConstraints { make in
            make.edges.equalTo(footerView.safeAreaLayoutGuide).inset(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        }
        
        bookGenreLabel.snp.makeConstraints { make in
            make.height.equalTo(15)
        }
        
        bookAuthorLabel.snp.makeConstraints { make in
            make.height.equalTo(15)
        
            
        }
        layoutIfNeeded()
    }
    
}
