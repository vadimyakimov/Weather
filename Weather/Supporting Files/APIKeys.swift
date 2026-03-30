//
//  APIKeys.swift
//  Weather
//
//  Created by Вадим on 21.02.2026.
//

import Foundation

class APIKeys {
    
    let keys: [String] = [
        "zpka_fb058e52d4e54d94b8496a4bb4e8f129_3b1b84bc", 
        "zpka_77068d894e22447eb4327fe5f62f2be3_904169fa",
        "zpka_96bce9c5d88646c48d887a346d01bc35_7240dedf",
    ]
    
    func getRandomAPIKey() -> String {
        let index = Int(arc4random_uniform(UInt32(self.keys.count)))
        return self.keys[index]
    }
}
