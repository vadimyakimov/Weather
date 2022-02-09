//
//  Manager.swift
//  Weather 2
//
//  Created by Вадим on 12.01.2022.
//

import Foundation
import UIKit
import CoreLocation

class Manager {
    
    // MARK: - Properties
    
    
    
    static let shared = Manager()
    
    var citiesArray: [City] {
        get {
            if let data = UserDefaults.standard.data(forKey: self.keyCitiesArrayUserDefaults),
               let decoded = try? JSONDecoder().decode([City].self, from: data) {
                return decoded
            }

            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: self.keyCitiesArrayUserDefaults)
            }
        }
    }
    
    var citiesAutocompleteArray: [CityAutocomplete] = []
    
    private let keyCitiesArrayUserDefaults = "CitiesArray"
    
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public funcs
    
    
    
    
    func fahrenheitFromCelsius(_ celsius: Int) -> Int {
        let fahrenheit = ((9 * celsius) / 5) + 32
        return fahrenheit
    }
        
    
    
}
