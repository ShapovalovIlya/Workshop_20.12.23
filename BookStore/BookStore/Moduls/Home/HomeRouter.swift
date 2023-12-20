//
//  HomeRouter.swift
//  BookStore
//
//  Created by Илья Шаповалов on 20.12.2023.
//

import UIKit

final class HomeRouter: BaseRouter {
    
    let navigationController: UINavigationController
    private let factory: AppFactory
    
    init(
        _ navigationController: UINavigationController,
        factory: AppFactory
    ) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func start() {
        navigationController.viewControllers = [factory.makeHomeViewController()]
    }
}
