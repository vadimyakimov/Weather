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
    
    @objc dynamic var string: String?
    
        
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.synchronize()
                        
        self.pushViewController(self.createRootViewController(), animated: true)
        self.setBackgroundColor()
    }
    
    // MARK: - UI setting funcs
    
    private func setBackgroundColor() {
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
            let searchScreen = SearchScreenViewController(isRoot: self.viewModel.isSearchRoot,
                                                          viewModel: self.viewModel.createSearchScreenViewModel())
            return searchScreen
        } else {
            let weatherScreen = CitiesPageViewController(viewModel: self.viewModel.createCitiesPageViewModel())
            return weatherScreen
        }
    }
}

// MARK: - 
// MARK: - Search Screen Delegate

extension MainNavigationController: SearchScreenViewControllerDelegate {
    
    func searchScreenViewController(didDirectToCityWithIndex index: Int) {
        if self.viewControllers.count == 1 {
            let rootController = self.createRootViewController()
            self.setViewControllers([rootController], animated: true)
        } else {
            if let rootController = self.viewControllers.first as? CitiesPageViewController {
                rootController.showCityViewController(withIndex: index)
            }
            self.popToRootViewController(animated: true)
        }
    }
}
