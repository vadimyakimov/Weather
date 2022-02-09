//
//  CitiesListViewController+extensions.swift
//  Weather 2
//
//  Created by Вадим on 17.01.2022.
//

import Foundation
import UIKit

// MARK: - Table View Data Source

extension CitiesListViewController: UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Manager.shared.citiesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CityTableViewCell.instanceFronNib()
        cell.configure(width: self.view.frame.width,
                       text: Manager.shared.citiesArray[indexPath.row].name,
                       isLocation: Manager.shared.citiesArray[indexPath.row].isLocated)
        return cell
    }
    
}

// MARK: - Table View Delegate

extension CitiesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Manager.shared.citiesArray.remove(at: indexPath.row)
            self.citiesListTableView.deleteRows(at: [indexPath], with: .automatic)
        }
        if Manager.shared.citiesArray.count == 0 {
            self.goToSearchScreen()
            self.searchScreen.navigationController?.isNavigationBarHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.citiesListViewController(didSelectRowAt: indexPath)
    }
    
}

// MARK: - Table View Drag Delegate

extension CitiesListViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        return [dragItem]
    }
    
}

// MARK: - Table View Drop Delegate

extension CitiesListViewController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                let city = Manager.shared.citiesArray[sourceIndexPath.row]
                Manager.shared.citiesArray.remove(at: sourceIndexPath.row)
                Manager.shared.citiesArray.insert(city, at: destinationIndexPath.row)
                tableView.reloadData()
            }
        }
    }
    
}
