//
//  MainNavigationControllerViewController.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    private let viewModel = MainNavigationViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        let weatherScreen = Bindable(CitiesCoreDataStack.shared.citiesList)
        weatherScreen.bind { citiesArray in
//            print(citiesArray.count)
        }
        
        self.pushViewController(rootViewController(), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationBarBackground()
    }
    
    private func setNavigationBarBackground() {
        if #available(iOS 13.0, *) {
            let appearence = UINavigationBarAppearance()
            appearence.backgroundColor = .systemBackground
            self.navigationBar.standardAppearance = appearence
            self.navigationBar.scrollEdgeAppearance = appearence
            self.view.backgroundColor = .systemBackground
        } else {
            self.navigationBar.backgroundColor = .white
            self.view.backgroundColor = .white
        }
    }
    
    private func rootViewController() -> UIViewController {
        
        if self.viewModel.isSearchRoot {
            let searchScreen = SearchScreenViewController()
            searchScreen.viewModel.delegate = self.viewModel
            return searchScreen
        } else {
            let weatherScreen = CitiesPageViewController()
            return weatherScreen
        }
    }
}

//
//class Fisrt: UIViewController {
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//    }
//
//}
//
//class Second: UIViewController {
//        
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        self.navigationController?.setViewControllers([self], animated: true)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//    
//}
