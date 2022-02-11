//
//  CitiesListViewControllerDelegate.swift
//  Weather 2
//
//  Created by Вадим on 18.01.2022.
//

import Foundation

protocol CitiesListViewControllerDelegate: AnyObject {
    func citiesListViewController(didSelectRowAt indexPath: IndexPath)
    func citiesListViewController(didUpdateCities citiesArray: [City])
    func citiesListViewControllerWillDisappear()
    
    func searchScreenViewController(didSelectRowAt indexPath: IndexPath)
    func searchScreenViewController(didLoadLocaleCity city: City)
}
