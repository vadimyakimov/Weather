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
    
    
    // viewControllerBefore
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let controller = (viewController as? CityViewController) else { return nil }
//        guard Manager.shared.citiesArray.count > 2, controller.cityIndex != 0 else { return nil }
        
        guard let index = Manager.shared.citiesArray.firstIndex(of: controller.city) else { return nil }
        return self.cityViewController(withIndex: index - 1)
    }

    // viewControllerAfter
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let controller = (viewController as? CityViewController) else { return nil }
//        guard Manager.shared.citiesArray.count > 2, controller.cityIndex != Manager.shared.citiesArray.count - 1 else { return nil }
        
        guard let index = Manager.shared.citiesArray.firstIndex(of: controller.city) else { return nil }
        return self.cityViewController(withIndex: index + 1)
    }
    
    
}

extension CitiesPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let controller = (pageViewController.viewControllers?.first as? CityViewController) else { return }
        guard let index = Manager.shared.citiesArray.firstIndex(of: controller.city) else { return }
//        self.currentCityIndex = index
        self.updatePageControl(index: index)
    }
    
}

// MARK: - Search Screen View Controller Delegate

extension CitiesPageViewController: SearchScreenViewControllerDelegate {
    
    func searchScreenViewController(didSelectRowAt indexPath: IndexPath) {

        let id = Manager.shared.citiesAutocompleteArray[indexPath.row].id
        let name = Manager.shared.citiesAutocompleteArray[indexPath.row].name
        let city = City(id: id, name: name)

        if let index = Manager.shared.citiesArray.firstIndex(of: city) {
            self.backToPageViewController(withIndex: index)
        } else {
            Manager.shared.citiesArray.append(City(id: id, name: name))
            self.backToPageViewController(withIndex: Manager.shared.citiesArray.count - 1)
        }
    }
}

// MARK: - Cities List View Controller Delegate

extension CitiesPageViewController: CitiesListViewControllerDelegate {

    func citiesListViewController(didSelectRowAt indexPath: IndexPath) {
        self.backToPageViewController(withIndex: indexPath.row)
    }

}

extension CitiesPageViewController: CityViewControllerDelegate {
    
    func cityViewController(willAppear controller: CityViewController) {
        let isDayTime = controller.city.currentWeather?.isDayTime ?? true
        self.addGradient(isDayTime: isDayTime)
    }
    
}
