//
//  CitiesPageViewController+extensions.swift
//  Weather 2
//
//  Created by Вадим on 13.01.2022.
//

import Foundation
import UIKit
import EMPageViewController

// MARK: - Page View Controller Data Source
/*
extension CitiesPageViewController: UIPageViewControllerDataSource {
    
    
    // viewControllerBefore
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let controller = (viewController as? CityViewController) else { return nil }
//        guard self.citiesArray.count > 2, controller.cityIndex != 0 else { return nil }
        
        guard let index = self.citiesArray.firstIndex(of: controller.city) else { return nil }
        return self.cityViewController(withIndex: index - 1)
    }

    // viewControllerAfter
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let controller = (viewController as? CityViewController) else { return nil }
//        guard self.citiesArray.count > 2, controller.cityIndex != self.citiesArray.count - 1 else { return nil }
        
        guard let index = self.citiesArray.firstIndex(of: controller.city) else { return nil }
        return self.cityViewController(withIndex: index + 1)
    }
}*/

extension CitiesPageViewController: EMPageViewControllerDataSource {
    func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let controller = (viewController as? CityViewController) else { return nil }
//        guard self.citiesArray.count > 2, controller.cityIndex != 0 else { return nil }
        
        guard let index = self.citiesArray.firstIndex(of: controller.city) else { return nil }
        return self.cityViewController(withIndex: index - 1)
    }
    
    func em_pageViewController(_ pageViewController: EMPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let controller = (viewController as? CityViewController) else { return nil }
//        guard self.citiesArray.count > 2, controller.cityIndex != self.citiesArray.count - 1 else { return nil }
        
        guard let index = self.citiesArray.firstIndex(of: controller.city) else { return nil }
        return self.cityViewController(withIndex: index + 1)
    }
    
    
}
/*
extension CitiesPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let controller = (pageViewController.viewControllers?.first as? CityViewController) else { return }
        guard let index = self.citiesArray.firstIndex(of: controller.city) else { return }
        
        self.updatePageControl(index: index)
    }
    
}*/

extension CitiesPageViewController: EMPageViewControllerDelegate {
    
    func em_pageViewController(_ pageViewController: EMPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController, progress: CGFloat) {

        var visibleController: CityViewController?

        if progress > 0.5 || progress < -0.5 {
            visibleController = destinationViewController as? CityViewController
        } else {
            visibleController = startingViewController as? CityViewController
        }

        guard let controller = visibleController else { return }
        guard let index = self.citiesArray.firstIndex(of: controller.city) else { return }

        self.updatePageControl(index: index)

        let isDayTime = controller.city.currentWeather?.isDayTime ?? true
        self.changeGradientColor(isDayTime: isDayTime)
    }
    
//    func em_pageViewController(_ pageViewController: EMPageViewController, didFinishScrollingFrom startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
//        guard let controller = destinationViewController as? CityViewController else { return }
//        guard let index = self.citiesArray.firstIndex(of: controller.city) else { return }
//
//        self.updatePageControl(index: index)
//
//        let isDayTime = controller.city.currentWeather?.isDayTime ?? true
//        self.changeGradientColor(isDayTime: isDayTime)
//    }
    
}

// MARK: - Search Screen View Controller Delegate
// MARK: - Cities List View Controller Delegate

extension CitiesPageViewController: SearchScreenViewControllerDelegate, CitiesListViewControllerDelegate {
    
    func searchScreenViewController(didSelectRowAt indexPath: IndexPath) {
        
        let id = Manager.shared.citiesAutocompleteArray[indexPath.row].id
        let name = Manager.shared.citiesAutocompleteArray[indexPath.row].name
        let city = City(id: id, name: name)

        if let index = self.citiesArray.firstIndex(of: city) {
            self.backToPageViewController(withIndex: index)
        } else {
            self.citiesArray.append(city)
            self.backToPageViewController(withIndex: self.citiesArray.count - 1)
        }
    }
    
    func searchScreenViewController(didLoadLocaleCity city: City) {
        
        if self.citiesArray.first?.isLocated == true {
            self.citiesArray.removeFirst()
        }
        self.citiesArray.insert(city, at: 0)
        
        self.backToPageViewController(withIndex: 0)
    }
    
    func citiesListViewController(didSelectRowAt indexPath: IndexPath) {
        self.backToPageViewController(withIndex: indexPath.row)
    }
    
    func citiesListViewControllerWillDisappear() {        
        self.checkDeletedViewControllers()
    }
    
}


// MARK: - City View Controller Delegate

extension CitiesPageViewController: CityViewControllerDelegate {
    
    func cityViewController(didUpdateCurrentWeatherFor city: City) {
        
        self.updateCity(city)
        
        guard let controller = self.selectedViewController as? CityViewController else { return }
        let isDayTime = controller.city.currentWeather?.isDayTime ?? true
        self.changeGradientColor(isDayTime: isDayTime)
    }
    
    func cityViewController(didUpdateHourlyForecastFor city: City) {
        self.updateCity(city)
    }
    
    func cityViewController(didUpdateDailyForecastFor city: City) {
        self.updateCity(city)
    }  
}
