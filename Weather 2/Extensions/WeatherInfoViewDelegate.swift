//
//  WeatherInfoViewDelegate.swift
//  Weather 2
//
//  Created by Вадим on 09.02.2022.
//

import Foundation

protocol WeatherInfoViewDelegate: AnyObject {
    func weatherInfoView(didUpdateCurrentWeatherFor city: City)
}
