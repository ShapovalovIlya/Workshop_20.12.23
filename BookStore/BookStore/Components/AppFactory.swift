//
//  AppFactory.swift
//  BookStore
//
//  Created by Илья Шаповалов on 20.12.2023.
//

import UIKit

protocol BaseRouter: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
    func back()
    func popToRoot()
}

extension BaseRouter {
    func back() {
        navigationController.popViewController(animated: true)
    }
    
    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}

protocol AppFactory: AnyObject {
    func makeLaunchController() -> UIViewController
    func makeTabbar(_ viewControllers: UIViewController...) -> UITabBarController
    func makeHomeViewController() -> UIViewController
    func makeCategoriesViewController() -> UIViewController
    func makeRootRouter(_ window: UIWindow?) -> RootRouter
    func makeHomeRouter() -> BaseRouter
    func makeCategoryRouter() -> BaseRouter
    func makeLikesRouter() -> BaseRouter
    func makeAccountRouter() -> BaseRouter
}

final class Factory: AppFactory {
    
    //MARK: - Routers
    func makeRootRouter(_ window: UIWindow?) -> RootRouter {
        RootRouter(window: window, factory: self)
    }
    
    func makeHomeRouter() -> BaseRouter {
        let navController = UINavigationController()
        navController.configureTabBarItem(
            "Home",
            image: "home_unselected",
            selectedImage: "home_selected"
        )
        let router = HomeRouter(navController, factory: self)
        router.start()
        return router
    }
    
    func makeCategoryRouter() -> BaseRouter {
        let navController = UINavigationController()
        navController.configureTabBarItem(
            "Categories",
            image: "categories_unselected",
            selectedImage: "categories_selected"
        )
        let router = CategoryRouter(navController, factory: self)
        router.start()
        return router
    }
    
    func makeLikesRouter() -> BaseRouter {
        let navController = UINavigationController()
        navController.configureTabBarItem(
            "Likes",
            image: "heart_unselected",
            selectedImage: "heart_selected"
        )
        let router = LikesRouter(navController, factory: self)
        router.start()
        return router
    }
    
    func makeAccountRouter() -> BaseRouter {
        let navController = UINavigationController()
        navController.configureTabBarItem(
            "Account",
            image: "account_unselected",
            selectedImage: "account_selected"
        )
        let router = AccountRouter(navController, factory: self)
        router.start()
        return router
    }
    
    //MARK: - UIViewController
    func makeTabbar(_ viewControllers: UIViewController...) -> UITabBarController {
        let tabbar = MainTabBarController()
        tabbar.viewControllers = viewControllers
        return tabbar
    }
    
    func makeLaunchController() -> UIViewController {
        LaunchViewController()
    }
    
    func makeHomeViewController() -> UIViewController {
        HomeVC(
            udManager: UserDefaultsManager(),
            homeView: HomeView(),
            search: SearchBarView()
        )
    }
    
    func makeCategoriesViewController() -> UIViewController {
        CategoriesVC()
    }
    
    func makeAccountViewController() -> UIViewController {
        AccountVC()
    }
   
}

