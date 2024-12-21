//
//  BackgroundGradient.swift
//  Weather
//
//  Created by Вадим on 21.12.2024.
//

import Foundation
import UIKit

class BackgroundGradient: CAGradientLayer {
    
    // MARK: - Properties
    
    var isDayTime: Bool? {
        didSet {
            if oldValue != self.isDayTime {
                self.updateGradient()
            }
        }
    }
    
    private let dayColors = [UIColor(red: 1, green: 0.7, blue: 0.48, alpha: 1).cgColor,
                     UIColor(red: 1, green: 0.49, blue: 0.49, alpha: 1).cgColor,
                     UIColor(red: 1, green: 0.82, blue: 0.24, alpha: 1).cgColor]
    private let nightColors = [UIColor(red: 0.25, green: 0, blue: 0.57, alpha: 1).cgColor,
                       UIColor(red: 0, green: 0.35, blue: 0.53, alpha: 1).cgColor,
                       UIColor(red: 0.02, green: 0, blue: 0.36, alpha: 1).cgColor]
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        
        self.opacity = 1
        self.locations = [0.0, 1.0]
        self.updateGradient()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Funcs
    
    private func updateGradient() {
        let isDayTime = self.isDayTime ?? true
        self.colors = isDayTime ? self.dayColors : self.nightColors
    }
    
}
