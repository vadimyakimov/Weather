//
//  ImageProviding.swift
//  Weather
//
//  Created by Вадим on 10.01.2025.
//

import UIKit

protocol ImageProviding {
    func getImage(_ iconNumber: Int) async -> UIImage?
}
