//
//  CitiesArray.swift
//  Weather 2
//
//  Created by Вадим on 06.02.2022.
//

import Foundation

class CitiesArray: Collection, Codable  {
    
    var startIndex: Int
    var endIndex: Int
    
    var location: City?
    var array: [City] = []
    
    typealias Index = Int
    
    
    internal init() {
        self.startIndex = -1
        self.endIndex = array.count
    }
    
    func index(after i: Int) -> Int {
        precondition(i < self.endIndex)
        return i + 1
    }
    
    subscript(position: Index) -> City? {
        if position == -1 {
            return location
        }
        return array[position]
    }
    
    
}
