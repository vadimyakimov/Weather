//
//  String+extensions.swift
//  Weather 2
//
//  Created by Вадим on 10.02.2022.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
