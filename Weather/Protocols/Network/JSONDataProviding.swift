//
//  JSONDataProviding.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//


protocol JSONDataProviding {
    func getJSON(from urlString: String) async -> Any?
}