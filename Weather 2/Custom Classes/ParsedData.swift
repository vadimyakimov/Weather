//
//  ParsedData.swift
//  Weather 2
//
//  Created by Вадим on 15.01.2022.
//

import Foundation

class ParsedData {
    
    // MARK: Properties
    
    var id: String?
    var name: String?
    
    var isDayTime: Bool?
    
    var temperatureCelsius: Int?
    var temperatureFahrenheit: Int?
    
    var weatherIcon: Int?
    var weatherText: String?
    
    init() { }
    
}
