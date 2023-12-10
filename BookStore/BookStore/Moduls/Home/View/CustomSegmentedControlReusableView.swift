//
//  CustomSegmentedControlReusableView.swift
//  BookStore
//
//  Created by Сазонов Станислав on 10.12.2023.
//

import UIKit
import SnapKit

final class CustomSegmentedControlReusableView: UICollectionReusableView {
    
    //MARK: UI Elements
    
    private let headerLabel = UILabel.makeLabel(
        text: "Top Books",
        font: .openSansBold(ofSize: 20),
        textColor: .elements
    )
    private let seeMoreButton = UIButton.makeButton(text: "see more", buttonColor: .clear, tintColor: .elements, borderWidth: 0)
    
    private let buttonTitles: [String] = ["This Week", "This Month", "This Year"]
    private lazy var segmentedControl: CustomSegmentedControl = CustomSegmentedControl(buttonTitles: buttonTitles)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .background
        addSubview(segmentedControl)
        
        addSubview(headerLabel)
        addSubview(seeMoreButton)
        
        setConstraints()
        
        seeMoreButton.addTarget(self, action: #selector(seeMoreButtonTapped), for: .touchUpInside)
        
    }
    
    func configureHeader(categoryName: String) {
        headerLabel.text = categoryName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Constraints
    
    private func setConstraints() {
        
        seeMoreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(10)
            make.top.equalToSuperview()
            
        }
        
        headerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-10)
            make.top.equalToSuperview()
            
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(50)
        }
        
    }
    
    // MARK: - Actions
    
    @objc func seeMoreButtonTapped() {
        UIView.animate(withDuration: 0.3, animations: {
            self.seeMoreButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.seeMoreButton.transform = CGAffineTransform.identity
            })
        })
    }
    
}




