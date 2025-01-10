//
//  CitiesListViewModelProtocol.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//

import CoreData

protocol CitiesListViewModelProtocol: SearchScreenViewModelCreator, CitiesCountProviding, EmptyStateProviding, CityElementProviding {
    
    var frc: NSFetchedResultsController<City> { get }
    var hasLocatedCity: Bool { get }
    
    func removeCityAt(_ index: Int)
    func moveCity(at sourceIndex: Int, to destinationIndex: Int) 
}
