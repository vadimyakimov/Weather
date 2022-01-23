//
//  CitiesPageViewController+extensions.swift
//  Weather 2
//
//  Created by Вадим on 13.01.2022.
//

import Foundation
import UIKit

// MARK: - Page View Controller Data Source

extension CitiesPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let controller = (pageViewController.viewControllers?.first as? CityViewController) else { return nil }
        guard Manager.shared.citiesArray.count > 2, controller.cityIndex != 0 else { return nil }
        return CityViewController(index: controller.cityIndex - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let controller = (pageViewController.viewControllers?.first as? CityViewController) else { return nil }
        guard Manager.shared.citiesArray.count > 2, controller.cityIndex != Manager.shared.citiesArray.count - 1 else { return nil }
        return CityViewController(index: controller.cityIndex + 1)
    }
    
}

extension CitiesPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let controller = (pageViewController.viewControllers?.first as? CityViewController) else { return }
        self.currentCityIndex = controller.cityIndex
    }
}

// MARK: - Search Screen View Controller Delegate

extension CitiesPageViewController: SearchScreenViewControllerDelegate {    
    
//    func searchScreenViewController(didSelectRowAt indexPath: IndexPath) {
//
//        let id = Manager.shared.citiesAutocompleteArray[indexPath.row].id
//        let name = Manager.shared.citiesAutocompleteArray[indexPath.row].name
//
//        for (index, city) in Manager.shared.citiesArray.enumerated() {
//            if city.id == id {
//                self.currentCityIndex = index
//                self.navigationController?.popToRootViewController(animated: true)
//                self.createCityViewController()
//                return
//            }
//        }
//
//        Manager.shared.citiesArray.append(City(id: id, name: name))
//
//        self.pageControl.numberOfPages = Manager.shared.citiesArray.count
//        self.currentCityIndex = Manager.shared.citiesArray.count - 1
//        self.navigationController?.popToRootViewController(animated: true)
//        self.createCityViewController()
//    }
    
}

// MARK: - Cities List View Controller Delegate

extension CitiesPageViewController: CitiesListViewControllerDelegate {
    
//    func citiesListViewController(didSelectRowAt indexPath: IndexPath) {
//        self.currentCityIndex = indexPath.row
//        self.navigationController?.popToRootViewController(animated: true)
//        self.createCityViewController()
//    }
    
}

extension CitiesPageViewController: CityViewControllerDelegate {
    
//    func cityViewController(didAppear controller: CityViewController) {
//        self.addGradient(isDayTime: controller.isDayTime)
//    }
    
}
