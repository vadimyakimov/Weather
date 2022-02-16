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
    
    
//    var locatedCity: City?
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public funcs
    
    func fahrenheitFromCelsius(_ celsius: Int) -> Int {
        let fahrenheit = ((9 * celsius) / 5) + 32
        return fahrenheit
    }
        
    
    
}
