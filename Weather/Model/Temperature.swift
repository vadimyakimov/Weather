//
//  Untitled.swift
//  Weather
//
//  Created by Вадим on 23.12.2024.
//

class Temperature {
    typealias Listener = (String) -> Void
    
    var isImperial: Bool {
        didSet {
            self.listener?(self.temperature)
        }
    }
    
    private let temperatureTuple: (celsius: Int16, fahrenheit: Int16)
    
    private var temperature: String {
        get {
            if isImperial {
                return "\(self.temperatureTuple.fahrenheit)ºF"
            } else {                
                return "\(self.temperatureTuple.celsius)ºC"
            }
        }
    }
    
    private var listener: Listener?
    
    init(temperatureCelsius: Int16, temperatureFahrenheit: Int16, isImperial: Bool) {
        self.temperatureTuple = (temperatureCelsius, temperatureFahrenheit)
        self.isImperial = isImperial
    }
    
    func bind(_ listener: Listener?) {
        self.listener = listener
        listener?(self.temperature)
    }
}
