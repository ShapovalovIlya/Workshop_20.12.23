//
//  MainTabBarController.swift
//  BookStore
//
//  Created by Alexander Altman on 04.12.2023.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    //MARK: - Dependencies
    private var shouldAnimateSelectedTabBarItem = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        generateTabBar()
        animateSelectedTabBarItem()
        delegate = self
    }
    
    //MARK: - Private methods
    private func generateTabBar() {
        tabBar.backgroundColor = UIColor.customLightGray
        let tabBarItemAppearance = UITabBarItem.appearance()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.openSansBold(ofSize: 14) ?? UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]
        tabBarItemAppearance.setTitleTextAttributes(attributes, for: .normal)
        tabBarItemAppearance.setTitleTextAttributes(attributes, for: .selected)
    }
    
    private func animateSelectedTabBarItem() {
        guard shouldAnimateSelectedTabBarItem else {
            return
        }
        
        guard let selectedViewController = selectedViewController else {
            return
        }
        
        guard let selectedIndex = viewControllers?.firstIndex(of: selectedViewController) else {
            return
        }
        
        let tabBarButton = tabBar.subviews[selectedIndex + 1]
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [.curveEaseInOut], animations: {
            tabBarButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [.curveEaseInOut], animations: {
                tabBarButton.transform = CGAffineTransform.identity
            }, completion: nil)
        }
        
        shouldAnimateSelectedTabBarItem = false
    }
}

//MARK: - UITabBarControllerDelegate
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        shouldAnimateSelectedTabBarItem = true
        animateSelectedTabBarItem()
    }
}

