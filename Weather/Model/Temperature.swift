//
//  Untitled.swift
//  Weather
//
//  Created by Вадим on 23.12.2024.
//

class Temperature {
    typealias Listener = (String) -> Void
    
    var isMetric: Bool {
        didSet {
            self.listener?(self.temperature)
        }
    }
    
    private let temperatureTuple: (celsius: Int16, fahrenheit: Int16)
    
    private var temperature: String {
        get {
            if isMetric {
                return "\(self.temperatureTuple.celsius)ºC"
            } else {
                return "\(self.temperatureTuple.fahrenheit)ºF"
            }
        }
    }
    
    private var listener: Listener?
    
    init(temperatureCelsius: Int16, temperatureFahrenheit: Int16, isMetric: Bool) {
        self.temperatureTuple = (temperatureCelsius, temperatureFahrenheit)
        self.isMetric = isMetric
    }
    
    func bind(_ listener: Listener?) {
        self.listener = listener
        listener?(self.temperature)
    }
}
