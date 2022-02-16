//
//  SearchScreenViewControllerDelegate.swift
//  Weather 2
//
//  Created by Вадим on 18.01.2022.
//

import Foundation

protocol SearchScreenViewControllerDelegate: AnyObject {
    func searchScreenViewController(didSelectRowAt indexPath: IndexPath, autocompletedCity: City)
    func searchScreenViewController(didLoadLocaleCity city: City)
}
