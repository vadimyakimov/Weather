//
//  CityElementProviding.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//


protocol CityElementProviding {
    func city(at index: Int) -> CityDataProviding?
}