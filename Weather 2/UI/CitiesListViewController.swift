//
//  CitiesListViewController.swift
//  Weather 2
//
//  Created by Вадим on 17.01.2022.
//

import UIKit

class CitiesListViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: CitiesListViewControllerDelegate?
    var citiesArray: [City]
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
              
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search,
                                           target: self,
                                           action: #selector(goToSearchScreen))
        self.navigationItem.rightBarButtonItem = searchButton
        self.navigationController?.isNavigationBarHidden = false
        
        self.addCitiesListTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.citiesListViewControllerWillDisappear()
    }
    
    
    // MARK: - Initializers
    
    init(citiesList: [City]) {
        self.citiesArray = citiesList
        super.init(nibName: nil, bundle: nil)
//        self.view.bounds.origin.y = -10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - IBActions
        
    @IBAction func goToSearchScreen() {
        let hidesBackButton = self.citiesArray.isEmpty ? true : false
        let searchScreen = SearchScreenViewController(hidesBackButton: hidesBackButton)
        searchScreen.delegate = self
        self.navigationController?.pushViewController(searchScreen, animated: true)
    }
    
    // MARK: - Flow funcs

    private func addCitiesListTableView() {
        let citiesListTableView = UITableView(frame: self.view.bounds)
        citiesListTableView.rowHeight = CityTableViewCell.cellHeight
        citiesListTableView.separatorStyle = .none
        
        citiesListTableView.dataSource = self
        citiesListTableView.delegate = self
        citiesListTableView.dragDelegate = self
        citiesListTableView.dropDelegate = self
        
        self.view.addSubview(citiesListTableView)
    }
}
