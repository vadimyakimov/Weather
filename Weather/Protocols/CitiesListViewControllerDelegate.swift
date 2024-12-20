//
//  Untitled.swift
//  Weather
//
//  Created by Вадим on 09.12.2024.
//

import Foundation
import CoreData

protocol CitiesListViewControllerDelegate: AnyObject {
    func citiesListViewController(didSelectRowAt indexPath: IndexPath)
    func citiesListViewControllerDidChangeContent()
}
