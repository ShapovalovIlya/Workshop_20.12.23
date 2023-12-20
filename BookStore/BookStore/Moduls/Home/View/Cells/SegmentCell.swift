//
//  SegmentCell.swift
//  BookStore
//
//  Created by Илья Шаповалов on 20.12.2023.
//

import UIKit

final class SegmentCell: UICollectionViewCell {
    static let identifier = SegmentCell.debugDescription()
    
    private let label: UILabel = .makeLabel(
        font: .systemFont(ofSize: 12),
        textColor: .black
    )
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .black : .white
            layer.borderColor = isSelected ? UIColor.white.cgColor : UIColor.black.cgColor
            label.textColor = isSelected ? .white : .black
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        addSubviewsTamicOff(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backgroundColor = nil
        layer.borderColor = nil
        label.text = nil
        label.textColor = nil
    }
    
    func configure(_ title: String) {
        label.text = title
    }
}
