//
//  Untitled.swift
//  Weather
//
//  Created by Вадим on 09.12.2024.
//

import Foundation
import CoreData

@MainActor
protocol CitiesListViewControllerDelegate: AnyObject {
    func citiesListViewController(didSelectRowAt indexPath: IndexPath)
    func citiesListViewControllerDidChangeContent()
}
