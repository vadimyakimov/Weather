//
//  SearchScreenViewController.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

import UIKit

class SearchScreenViewController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel: SearchScreenViewModelProtocol
    
    private let isRoot: Bool
    
    private let searchTableView = UITableView()
    private let autocompleteSearchController = UISearchController()
    private var alertController: UIAlertController?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.delegate = self.navigationController as? SearchScreenViewControllerDelegate
        self.bindViewModel()
                
        self.addSearchController()
        self.addSearchTableView()
        
        self.registerForKeyboardNotifications()
    }
    
    
    // MARK: - Initializers
    
    init(isRoot: Bool = false, viewModel: SearchScreenViewModelProtocol) {
        self.viewModel = viewModel
        self.isRoot = isRoot
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Binding funcs
    
    private func bindViewModel() {
        
        self.viewModel.citiesAutocompleteArray.bind { [unowned self] _ in
            self.searchTableView.reloadData()
        }
        
        self.viewModel.isLocationLoading.bind { [unowned self] state in            
            switch state {
            case .initial:
                self.alertController?.dismiss(animated: false)
                self.setLoadingAnimation(false)
            case .loading:
                self.setLoadingAnimation(true)
            case .error:
                self.setLoadingAnimation(false)
                self.showLocationErrorAlert()
            }
        }
    }
    
    // MARK: - NotificationCenter funcs
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - IBAction
    
    @IBAction private func handle(keyboardNotification notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        let tableViewBottomConstraint = self.view.constraints.filter({     // Bottom constrain
            guard let firstItem = $0.firstItem as? NSObject else { return false }
            return firstItem == self.searchTableView && $0.firstAttribute == .bottom
        }).first
        
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            tableViewBottomConstraint?.constant = -keyboardFrame.height
        default:
            tableViewBottomConstraint?.constant = 0
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func addSearchController() {
                
        self.autocompleteSearchController.searchResultsUpdater = self
        self.autocompleteSearchController.delegate = self
                
        if self.isRoot {
            self.navigationItem.titleView = self.autocompleteSearchController.searchBar
            self.autocompleteSearchController.hidesNavigationBarDuringPresentation = false
        } else {
            self.navigationItem.searchController = self.autocompleteSearchController
        }
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.autocompleteSearchController.isActive = true
    }
    
    private func addSearchTableView() {
        
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        
        self.searchTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.searchTableView)
        
        NSLayoutConstraint.activate([
            self.searchTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.searchTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.searchTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.searchTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
                
        self.searchTableView.rowHeight = CityTableViewCell.cellHeight
        self.searchTableView.separatorStyle = .none
    }
    
    // MARK: - Location funcs
    
    private func setLoadingAnimation(_ isLoading: Bool) {
        guard let cell = self.searchTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CityTableViewCell else { return }
        if isLoading {
            cell.startLoading()
        } else {
            cell.stopLoading()
        }
    }
    
    private func showLocationErrorAlert() {
        let errorTitle = "Failed to find your location".localized()
        let errorMessage = "Check if your location is allowed in the settings, or try again later".localized()
        
        self.alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        let alert = self.alertController
        
        let settingsAction = UIAlertAction(title: "Settings".localized(), style: .default) { action in
            if let bundleId = Bundle.main.bundleIdentifier,
               let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                UIApplication.shared.open(url, options: [:])
            }
        }
        alert?.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alert?.addAction(cancelAction)
        
        guard let alert else { return }
        self.present(alert, animated: true)
    }
}

// MARK: -
// MARK: - Search Results Updating

extension SearchScreenViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else { return }
        self.viewModel.fetchAutocompleteArray(for: searchText)
    }
}

// MARK: - Search Controller Delegate

extension SearchScreenViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
}


// MARK: - Table View Data Source

extension SearchScreenViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // For detecting location
        } else {
            return self.viewModel.citiesCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = CityTableViewCell.instanceFronNib()
        let width = self.view.frame.width
        if indexPath.section == 0 {
            cell.configure(width: width, text: "My location".localized(), isLocation: true)
        } else {
            guard let autocompletedCity = self.viewModel.city(at: indexPath.row) else { return UITableViewCell() }
            cell.configure(width: width, text: autocompletedCity.name)
        }
        return cell
    }
}

// MARK: - Table View Updating

extension SearchScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.autocompleteSearchController.searchBar.resignFirstResponder()
        self.autocompleteSearchController.hidesNavigationBarDuringPresentation = false
        self.viewModel.handleSelectedRow(at: indexPath)
    }
}
