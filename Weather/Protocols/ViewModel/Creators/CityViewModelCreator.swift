//
//  CityViewModelCreator.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//


protocol CityViewModelCreator {
    func createCityViewModel(withIndex index: Int) -> CityViewModelProtocol
}