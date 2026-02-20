//
//  APIKeys.swift
//  Weather
//
//  Created by Вадим on 21.02.2026.
//

import Foundation

class APIKeys {
    
    let keys: [String] = [
        "zpka_e6853d8530814235918de26dd973940a_94b2d220", // expires on Mar 7, 2026
        "zpka_539441e800c74574ba635d773c2990a7_21888991", // expires on Mar 7, 2026
        "zpka_484291e90a31439a95d81dce4ff1f7c1_a5807c76", // expires on Mar 7, 2026
    ]
    
    func getRandomAPIKey() -> String {
        let index = Int(arc4random_uniform(UInt32(self.keys.count)))
        return self.keys[index]
    }
}
