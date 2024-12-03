//
//  SearchScreenViewController.swift
//  Weather
//
//  Created by Вадим on 02.12.2024.
//

import UIKit

class SearchScreenViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel = SearchScreenViewModel()
    
    var searchTableView = UITableView()
    let autocompleteSearchController = UISearchController()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindViewModel()
        
        self.registerForKeyboardNotifications()
        
        self.addSearchController()
        self.addSearchTableView()
        
        //        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Initializers
    //
    //    init(hidesBackButton: Bool = false) {
    ////        self.hidesBackButton = hidesBackButton
    //        super.init(nibName: nil, bundle: nil)
    //    }
    //
    //    required init?(coder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Binding funcs
    
    func bindViewModel() {
        
        self.viewModel.citiesAutocompleteArray.bind { [unowned self] _ in
            DispatchQueue.main.async {
                self.searchTableView.reloadData()
            }
        }
        
        self.viewModel.isLocationLoading.bind { [unowned self] isLoading in
            self.setLoadingAnimation(isLoading)
        }
        
        self.viewModel.locationError?.bind { [unowned self] _ in
            self.showLocationErrorAlert()
        }
    }
    
    // MARK: - NotificationCenter funcs
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handle(keyboardNotification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - IBAction
    
    @IBAction private func handle(keyboardNotification notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardRectangle = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        var isKeyboardShown: Bool
        
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            isKeyboardShown = true
        default:
            isKeyboardShown = false
        }
        
        self.updateSearchTableViewFrame(isKeyboardShown: isKeyboardShown,
                                        keyboardHeight: keyboardRectangle.height,
                                        withDuration: animationDuration)
    }
    
    // MARK: - UI configuration funcs
    
    private func updateSearchTableViewFrame(isKeyboardShown: Bool,
                                            keyboardHeight: CGFloat,
                                            withDuration duration: TimeInterval) {
        var height = self.view.frame.height
        
        if isKeyboardShown {
            height -= keyboardHeight
            if let navigationBarHeight = self.navigationController?.navigationBar.frame.height {
                height += navigationBarHeight
                height -= self.autocompleteSearchController.searchBar.frame.height
            }
        }
        
        UIView.animate(withDuration: duration) {
            self.searchTableView.frame.size.height = height
        }
        self.view.layoutIfNeeded()
    }
    
    private func addSearchController() {
        self.autocompleteSearchController.searchResultsUpdater = self
        self.autocompleteSearchController.delegate = self
        
//        if self.hidesBackButton {
            self.navigationItem.titleView = self.autocompleteSearchController.searchBar
//            self.navigationItem.hidesBackButton = true
            self.autocompleteSearchController.hidesNavigationBarDuringPresentation = false
//        } else {
//            self.navigationItem.searchController = self.autocompleteSearchController
//        }
        
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.autocompleteSearchController.isActive = true
    }
    
    private func addSearchTableView() {
        
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        
        self.searchTableView.frame = self.view.bounds
        self.searchTableView.rowHeight = CityTableViewCell.cellHeight
        self.searchTableView.separatorStyle = .none
        self.view.addSubview(self.searchTableView)
        
    }
    
    // MARK: - Location funcs
        
    func setLoadingAnimation(_ isLoading: Bool) {
        guard let cell = self.searchTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CityTableViewCell else { return }
        if isLoading {
            cell.startLoading()
        } else {
            cell.stopLoading()
        }
    }
    
    func showLocationErrorAlert() {
        let errorTitle = "Failed to find your location".localized()
        let errorMessage = "Check if your location is allowed in the settings, or try again later".localized()
        
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings".localized(), style: .default) { action in
            if let bundleId = Bundle.main.bundleIdentifier,
               let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alert.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
}

//MARK: - Search Results Updating

extension SearchScreenViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else { return }
        self.viewModel.fetchAutocompleteArray(for: searchText)
    }
}

//MARK: - Search Controller Delegate

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
            return self.viewModel.getCitiesCount()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = CityTableViewCell.instanceFronNib()
        let width = self.view.frame.width
        if indexPath.section == 0 {
            cell.configure(width: width, text: "My location".localized(), isLocation: true)
        } else {
            guard let autocompletedCity = self.viewModel.getCity(atIndexPath: indexPath) else { return UITableViewCell() }
            
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

        if indexPath.section == 0 {
            self.setLoadingAnimation(true)
//            self.requestLocation()
        } else {
            guard let city = self.viewModel.getCity(atIndexPath: indexPath) else { return }
//            self.delegate?.searchScreenViewController(didSelectRowAt: indexPath, autocompletedCity: city)
        }
    }
}
