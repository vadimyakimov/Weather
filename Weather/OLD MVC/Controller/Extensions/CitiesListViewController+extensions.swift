//import Foundation
//import UIKit
//
//// MARK: - Table View Data Source
//
//extension CitiesListViewController: UITableViewDataSource {
//        
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.citiesArray.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = CityTableViewCell.instanceFronNib()
//        cell.configure(width: self.view.frame.width,
//                       text: self.citiesArray[indexPath.row].name,
//                       isLocation: self.citiesArray[indexPath.row].isLocated)
//        return cell
//    }
//    
//}
//
//// MARK: - Table View Delegate
//
//extension CitiesListViewController: UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            self.delegate?.citiesListViewController(shouldRemoveCityAt: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//        if self.citiesArray.count == 0 {
//            self.goToSearchScreen()
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.delegate?.citiesListViewController(didSelectRowAt: indexPath)
//    }
//    
//}
//
//// MARK: - Table View Drag Delegate
//
//extension CitiesListViewController: UITableViewDragDelegate {
//    
//    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        
//        if self.citiesArray.first?.isLocated == true, indexPath.row == 0 {
//            return []
//        }
//        
//        let dragItem = UIDragItem(itemProvider: NSItemProvider())
//        return [dragItem]
//    }
//    
//}
//
//// MARK: - Table View Drop Delegate
//
//extension CitiesListViewController: UITableViewDropDelegate {
//    
//    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
//        if self.citiesArray.first?.isLocated == true, destinationIndexPath?.row == 0 {
//            return UITableViewDropProposal(operation: .forbidden)
//        }
//        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
//    }
//    
//    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
//        let destinationIndexPath: IndexPath
//        if let indexPath = coordinator.destinationIndexPath {
//            destinationIndexPath = indexPath
//        } else {
//            let section = tableView.numberOfSections - 1
//            let row = tableView.numberOfRows(inSection: section)
//            destinationIndexPath = IndexPath(row: row, section: section)
//        }
//        
//        for item in coordinator.items {
//            if let sourceIndexPath = item.sourceIndexPath {
//                self.delegate?.citiesListViewController(shouldMoveCityAt: sourceIndexPath.row, to: destinationIndexPath.row)
//                tableView.reloadData()
//            }
//        }        
//    }
//    
//}
//
//// MARK: - Search Screen View Controller Delegate
//
//extension CitiesListViewController: SearchScreenViewControllerDelegate {
//    
//    func searchScreenViewController(didSelectRowAt indexPath: IndexPath, autocompletedCity: City) {
//        delegate?.searchScreenViewController(didSelectRowAt: indexPath, autocompletedCity: autocompletedCity)
//    }
//    
//    func searchScreenViewController(didLoadLocaleCity city: City) {
//        delegate?.searchScreenViewController(didLoadLocaleCity: city)
//    }
//    
//}
