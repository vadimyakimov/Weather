//
//  JSONLoader.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//

import Foundation

class JSONLoader: JSONDataProviding {
    
    func getJSON(from urlString: String) async -> Any? {
        do {
            guard let data = try await self.fetchRequest(from: urlString) else { return nil }
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            return json
        } catch {
            return nil
        }
    }
    
    private func fetchRequest(from urlString: String) async throws -> Data? {
        guard let url = URL(string: urlString) else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
