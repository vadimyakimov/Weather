//
//  SearchScreenViewModelProtocol.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//

import Foundation

protocol SearchScreenViewModelProtocol: CitiesCountProviding, CityElementProviding {
    var delegate: SearchScreenViewControllerDelegate? { get set }
    var citiesAutocompleteArray: Bindable<[CityDataProviding]> { get }
    var isLocationLoading: Bindable<GeoDetectingState> { get }
    
    func fetchAutocompleteArray(for searchText: String)
    func handleSelectedRow(at indexPath: IndexPath)
}
