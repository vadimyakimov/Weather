//
//  CitiesListViewController.swift
//  Weather
//
//  Created by Вадим on 09.12.2024.
//

import UIKit
import CoreData

class CitiesListViewController: UIViewController {
    
    private let viewModel: CitiesListViewModelProtocol
    weak var delegate: CitiesListViewControllerDelegate?

    private let citiesListTableView = UITableView()
    
    private var isContentChanged = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let searchButton = UIBarButtonItem(barButtonSystemItem: .search,
                                           target: self,
                                           action: #selector(goToSearchScreen))
        self.navigationItem.rightBarButtonItem = searchButton
        
        self.addCitiesListTableView()
        
        if #available(iOS 13, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isContentChanged {
            delegate?.citiesListViewControllerDidChangeContent()
        }
    }
        
    // MARK: - Initializers
    
    init(viewModel: CitiesListViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.frc.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBActions

    @IBAction private func goToSearchScreen() {
        let isSearchRoot = self.viewModel.isEmpty ? true : false
        let searchScreen = SearchScreenViewController(isRoot: isSearchRoot,
                                                      viewModel: self.viewModel.createSearchScreenViewModel())
        if isSearchRoot {
            self.navigationController?.setViewControllers([searchScreen], animated: true)
        } else {
            self.navigationController?.pushViewController(searchScreen, animated: true)
        }
    }
    
    // MARK: - Flow funcs
    
    private func addCitiesListTableView() {
        
        self.citiesListTableView.rowHeight = CityTableViewCell.cellHeight
        self.citiesListTableView.separatorStyle = .none
        self.citiesListTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.citiesListTableView)
        
        NSLayoutConstraint.activate([
            self.citiesListTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.citiesListTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.citiesListTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.citiesListTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
                
        self.citiesListTableView.dataSource = self
        self.citiesListTableView.delegate = self
        self.citiesListTableView.dragDelegate = self
        self.citiesListTableView.dropDelegate = self
    }
}

// MARK: -
// MARK: - Table View Data Source

extension CitiesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.citiesCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let city = self.viewModel.frc.object(at: indexPath)
        let cell = CityTableViewCell.instanceFronNib()
        cell.configure(width: self.view.frame.width,
                       text: city.name,
                       isLocation: city.isLocated)
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
            self.viewModel.removeCityAt(indexPath.row)
        }
        if self.viewModel.isEmpty {
            self.goToSearchScreen()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.citiesListViewController(didSelectRowAt: indexPath)
    }
}

// MARK: - Table View Drag&Drop Delegate

extension CitiesListViewController: UITableViewDragDelegate, UITableViewDropDelegate {

    // MARK: UITableViewDragDelegate
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        guard let item = self.viewModel.city(at: indexPath.row),
              !item.isLocated else { return [] }
        
        let itemProvider = NSItemProvider(object: item.name as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    // MARK: UITableViewDropDelegate
    
    func tableView(_ tableView: UITableView,
                   dropSessionDidUpdate session: UIDropSession,
                   withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if self.viewModel.hasLocatedCity == true, destinationIndexPath?.row == 0 {
            return UITableViewDropProposal(operation: .forbidden)
        }
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func tableView(_ tableView: UITableView,
                   performDropWith coordinator: UITableViewDropCoordinator) {
        
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }

        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                self.viewModel.moveCity(at: sourceIndexPath.row, to: destinationIndexPath.row)
                coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
            }
        }
    }
}

// MARK: - Fetched Results Controller Delegate

extension CitiesListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard self.citiesListTableView.window != nil else { return }
            self.citiesListTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard self.citiesListTableView.window != nil else { return }
        self.citiesListTableView.endUpdates()
        self.isContentChanged = true
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        guard self.citiesListTableView.window != nil else { return }
        
        self.citiesListTableView.performBatchUpdates {
            switch type {
            case .delete:
                guard let indexPath = indexPath else { return }
                self.citiesListTableView.deleteRows(at: [indexPath], with: .none)
            case .move:
                guard let sourceIndexPath = indexPath,
                      let destinationIndexPath = newIndexPath else { return }
                self.citiesListTableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
            default:
                break
            }
        }
    }
}
