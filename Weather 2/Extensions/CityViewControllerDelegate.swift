//
//  CityViewControllerDelegate.swift
//  Weather 2
//
//  Created by Вадим on 22.01.2022.
//

import Foundation

protocol CityViewControllerDelegate: AnyObject {
    func cityViewController(didAppear controller: CityViewController)
}
