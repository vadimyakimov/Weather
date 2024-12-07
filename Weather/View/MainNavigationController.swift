//
//  MainNavigationControllerViewController.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    // MARK: - Properties
    
    private let viewModel = MainNavigationViewModel()
    
    private var indexPageViewControler = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let count = CitiesCoreDataStack.shared.citiesList.count
//        print(count)
//        for i in 0..<count {
//            CitiesCoreDataStack.shared.deleteCity(at: i)
//        }
//        print(count)
        
        //        let weatherScreen = Bindable(CitiesCoreDataStack.shared.citiesList)
        //        weatherScreen.bind { citiesArray in
        ////            print(citiesArray.count)
        //        }
        //        self.control
        
        self.pushViewController(self.createRootViewController(), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationBarBackground()
    }
    
    // MARK: - UI setting funcs
    
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
    
    // MARK: - Navigation funcs
    
    private func createRootViewController() -> UIViewController {
        if self.viewModel.isSearchRoot {
            let searchScreen = SearchScreenViewController(isRoot: self.viewModel.isSearchRoot)
            searchScreen.viewModel.delegate = self
            return searchScreen
        } else {
            let weatherScreen = CitiesPageViewController(atIndex: self.indexPageViewControler,
                                                         viewModel: self.viewModel.createCitiesPageViewModel())
            return weatherScreen
        }
    }
    
    private func popToRootViewController(isSearchRoot: Bool) {
        if isSearchRoot {
            self.setViewControllers([self.createRootViewController()], animated: true)
        } else {
            self.popToRootViewController(animated: true)
        }
    }
    
}

// MARK: - Search Screen Delegate

extension MainNavigationController: SearchScreenViewControllerDelegate {
    
    func searchScreenViewController(isRoot: Bool, didSelectAutocompletedCity city: City) {
        
        if let index = self.viewModel.firstIndexInCityList(of: city) {
            self.indexPageViewControler = index
        } else {
            self.viewModel.addNewCity(city)
            self.indexPageViewControler = self.viewModel.citiesCount - 1
        }
        self.popToRootViewController(isSearchRoot: isRoot)
    }
    
    func searchScreenViewController(isRoot: Bool, didLoadLocalCity city: City) {
        self.viewModel.addNewCity(city)
        self.indexPageViewControler = 0
        self.popToRootViewController(isSearchRoot: isRoot)
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
