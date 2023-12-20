//
//  UINavigationController.swift
//  BookStore
//
//  Created by Илья Шаповалов on 20.12.2023.
//

import UIKit

extension UINavigationController {
    func configureTabBarItem(_ title: String, image: String, selectedImage: String) {
        let offset: CGFloat = 5
        self.tabBarItem.imageInsets = UIEdgeInsets(top: offset, left: 0, bottom: -offset, right: 0)
        self.tabBarItem.image = UIImage(named: image)?.withRenderingMode(.alwaysOriginal)
        self.tabBarItem.selectedImage = UIImage(named: selectedImage)?.withRenderingMode(.alwaysOriginal)
        self.tabBarItem.title = title
        let titleOffset = UIOffset(horizontal: 0, vertical: 4)
        self.tabBarItem.titlePositionAdjustment = titleOffset
    }
}
