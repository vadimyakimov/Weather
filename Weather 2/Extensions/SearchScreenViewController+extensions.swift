//
//  SearchScreenViewController+extensions.swift
//  Weather 2
//
//  Created by Вадим on 13.01.2022.
//

import UIKit
import CoreLocation

// MARK: - Table View Data Source

extension SearchScreenViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return Manager.shared.citiesAutocompleteArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.searchCellId, for: indexPath) as? CityTableViewCell else { return UITableViewCell() }
        if indexPath.section == 0 {
            cell.configure(withSize: CGSize(width: self.view.frame.width,
                                            height: self.searchRowHeight),
                           text: "My location", isLocation: true)
        } else {
            cell.configure(withSize: CGSize(width: self.view.frame.width,
                                            height: self.searchRowHeight),
                           text: Manager.shared.citiesAutocompleteArray[indexPath.row].name)
        }
        return cell
    }
}

extension SearchScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.getLocation {
                self.delegate?.searchScreenViewController(didSelectRowAt: indexPath)
            }
        } else {
            self.delegate?.searchScreenViewController(didSelectRowAt: indexPath)            
        }
    }
    
}

// MARK: - Search Bar Delegate

extension SearchScreenViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.autocompleteTimer?.invalidate()
        self.autocompleteTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { _ in
            Manager.shared.autocomplete(for: searchText) {
                DispatchQueue.main.async {
                    self.autocompleteTimer?.invalidate()
                    self.searchTableView.reloadData()
                }
            }            
        })      
    }

}

extension SearchScreenViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {  let alert = UIAlertController(title: "Location error", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

