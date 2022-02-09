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
    
    var citiesListTableView = UITableView()
    
    let searchScreen = SearchScreenViewController()
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.citiesListTableView.dataSource = self
        self.citiesListTableView.delegate = self
        self.citiesListTableView.dragDelegate = self
        self.citiesListTableView.dropDelegate = self
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search,
                                   target: self,
                                   action: #selector(goToSearchScreen))
        self.navigationItem.rightBarButtonItem = searchButton
        
        
        self.navigationController?.isNavigationBarHidden = false
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        self.setCitiesListTableViewFrame()
        self.citiesListTableView.rowHeight = CityTableViewCell.cellHeight
        self.citiesListTableView.separatorStyle = .none
        self.view.addSubview(self.citiesListTableView)
        
    }
    
    
    // MARK: - IBActions
        
    @IBAction func goToSearchScreen() {
        self.navigationController?.pushViewController(self.searchScreen, animated: true)
    }
    
    // MARK: - Flow funcs

    private func setCitiesListTableViewFrame() {
        self.citiesListTableView.frame = CGRect(x: 0,
                                                y: self.view.safeAreaInsets.top,
                                                width: self.view.frame.size.width,
                                                height: self.view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom)
    }

}
