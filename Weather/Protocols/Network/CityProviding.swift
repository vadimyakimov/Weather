//
//  CityProviding.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//

import CoreLocation

protocol CityProviding {
    func autocomplete(for text: String) async -> [CityDataProviding]?
    func geopositionCity(for location: CLLocationCoordinate2D) async -> CityDataProviding?
}
