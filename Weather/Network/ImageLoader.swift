//
//  ImageLoader.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//

import Foundation
import Kingfisher

class ImageLoader: ImageProviding {
    
    private init() {}
    static let shared = ImageLoader()
    
    func getImage(_ iconNumber: Int) async -> UIImage? {
        
        let numberFormatted = String(format: "%02d", iconNumber)
        let urlString = "https://developer.accuweather.com/sites/default/files/\(numberFormatted)-s.png"
        guard let url = URL(string: urlString) else { return nil }
                
        do {
            let result = try await KingfisherManager.shared.retrieveImage(with: url)
            return result.image
        } catch {
            print("Error during getImage: \(error.localizedDescription)")
            return nil
        }
    }
}
