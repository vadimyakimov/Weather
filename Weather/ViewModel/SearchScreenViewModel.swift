//
//  SearchScreenViewModel.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

import Foundation
import UIKit
import CoreLocation

class SearchScreenViewModel: NSObject {
    
    // MARK: - Properties
    
    weak var delegate: SearchScreenViewControllerDelegate?
    
    var isRoot = false
    
    var citiesAutocompleteArray = Bindable([City]())
    
    private lazy var locationManager = CLLocationManager()
    var isLocationLoading = Bindable(false)
    var locationError = Bindable<Error?>(nil)
    
    private lazy var autocompleteTimer = Timer()
    private let timerInterval = 0.7
    
    //    let hidesBackButton: Bool
    
    // MARK: - Getting data
    
    func fetchAutocompleteArray(for searchText: String) {
        
        self.autocompleteTimer.invalidate()
        self.autocompleteTimer = Timer.scheduledTimer(withTimeInterval: self.timerInterval,
                                                      repeats: false,
                                                      block: { _ in
            NetworkManager.shared.autocomplete(for: searchText) { [unowned self] cityArray in
                self.citiesAutocompleteArray.value = cityArray
                self.autocompleteTimer.invalidate()
            }
        })
    }
    
    func getCitiesCount() -> Int {
        return self.citiesAutocompleteArray.value.count
    }
    
    func getCity(atIndexPath indexPath: IndexPath) -> City? {
        return self.citiesAutocompleteArray.value[safe: indexPath.row]
    }
    
    // MARK: - Detecting city funcs
    
    func passSelectedRow(at indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.requestLocation()
        } else {
            guard let city = self.getCity(atIndexPath: indexPath) else { return }
            self.delegate?.searchScreenViewController(isRoot: self.isRoot, didSelectAutocompletedCity: city)
        }
    }
    
    private func requestLocation() {
                
        self.isLocationLoading.value = true
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.requestLocation()
    }
    
}

// MARK: - Location Manager Delegate

extension SearchScreenViewModel: CLLocationManagerDelegate {
    
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
            guard let location = manager.location else {
                self.locationError.value = NSError()
                return
            }
            NetworkManager.shared.geopositionCity(for: location.coordinate) { [unowned self] city in
                self.delegate?.searchScreenViewController(isRoot: self.isRoot, didLoadLocalCity: city)
            }
        }
    
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    
            self.isLocationLoading.value = false
    
            if #available(iOS 14.0, *), locationManager.authorizationStatus == .notDetermined {
                    return
            } else {
                self.locationError.value = error
            }
        }
    
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                self.isLocationLoading.value = true
                manager.requestLocation()
            }
        }
}
