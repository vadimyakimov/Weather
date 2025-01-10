//
//  CityManagedEntity.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//

import CoreData

protocol CityManagedEntity: NSManagedObject {
    var city: City? { get set }
}
