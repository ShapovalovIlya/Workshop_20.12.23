//
//  RootRouter.swift
//  BookStore
//
//  Created by Илья Шаповалов on 20.12.2023.
//

import UIKit

final class RootRouter {
    private let window: UIWindow?
    private let factory: AppFactory
    
    init(
        window: UIWindow?,
        factory: AppFactory
    ) {
        self.window = window
        self.factory = factory
    }
    
    func start() {
        let savedDarkMode = UserDefaults.standard.bool(forKey: "AppDarkMode")
        let selectedTheme: UIUserInterfaceStyle = savedDarkMode ? .dark : .light
        
        window?.overrideUserInterfaceStyle = selectedTheme
        
        window?.rootViewController = factory.makeLaunchController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: showMainTabbar)
        window?.makeKeyAndVisible()
    }
    
    func showMainTabbar() {
        window?.rootViewController = factory.makeTabbar(
            factory.makeHomeRouter().navigationController,
            factory.makeCategoryRouter().navigationController,
            factory.makeLikesRouter().navigationController,
            factory.makeAccountRouter().navigationController
        )
    }
}
