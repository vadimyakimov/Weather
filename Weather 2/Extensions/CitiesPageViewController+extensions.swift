//
//  CitiesPageViewController+extensions.swift
//  Weather 2
//
//  Created by Вадим on 13.01.2022.
//

import Foundation
import UIKit
import EMPageViewController

// MARK: - EM Page View Controller Data Source

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

// MARK: - EM Page View Controller Delegate

extension CitiesPageViewController: EMPageViewControllerDelegate {
    
    func em_pageViewController(_ pageViewController: EMPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController, progress: CGFloat) {

        guard let destinationViewController = destinationViewController as? CityViewController,
              let startingViewController = startingViewController as? CityViewController else { return }
              
        var visibleViewController: CityViewController
        if abs(progress) > 0.5 {
            visibleViewController = destinationViewController
        } else {
            visibleViewController = startingViewController
        }        
        let isDayTime = visibleViewController.city.currentWeather?.isDayTime ?? true
        self.changeGradientColor(isDayTime: isDayTime)
                
        
        self.nameLabel.text = startingViewController.city.name
        self.newNameLabel.text = destinationViewController.city.name
        
        switch abs(progress) {
        case 0:
            self.newNameLabel.frame.origin.x = self.horizontalOffset + self.view.frame.width
        case 0..<1:
            let oldLabelGraph = -((pow(Double(progress), 3) / 2) + (progress / 2))
            let newLabelGraph = (abs(progress) / progress) * ((pow(Double(progress), 2) / 2) -
                                ((abs(progress) / progress) * progress * 1.5) + 1)
                        
            self.nameLabel.frame.origin.x = self.horizontalOffset + (self.view.frame.width * oldLabelGraph)
            self.newNameLabel.frame.origin.x = self.horizontalOffset + (self.view.frame.width * newLabelGraph)
            
            
            let oldLabelOpacityGraph = -pow(Double(progress), 2) + 1
            let newLabelOpacityGraph = pow(progress, 2)
            
            self.nameLabel.layer.opacity = Float(oldLabelOpacityGraph)
            self.newNameLabel.layer.opacity = Float(newLabelOpacityGraph)
        default:
            break
        }
    }
    
    func em_pageViewController(_ pageViewController: EMPageViewController, didFinishScrollingFrom startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        guard transitionSuccessful,
              let controller = destinationViewController as? CityViewController,
              let index = self.citiesArray.firstIndex(of: controller.city) else { return }
        self.updatePageControl(index: index)
    }
    
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
    
    func citiesListViewController(didUpdateCities citiesArray: [City]) {
        self.citiesArray = citiesArray
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
    
    func cityViewController(scrollViewDidScroll scrollView: UIScrollView) {
        let fontSize = self.nameLabelFontSize - scrollView.contentOffset.y
        if fontSize < self.nameLabelFontSize * 2 &&
           fontSize > self.nameLabelMinimumFontSize {
            self.nameLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .light)
            self.newNameLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .light)
        }
    }

}
