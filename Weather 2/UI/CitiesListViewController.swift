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
        
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
              
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
        
    }
    
    override func viewSafeAreaInsetsDidChange() {
        self.addCitiesListTableView(frame: CGRect(x: 0,
                                                  y: self.view.safeAreaInsets.top,
                                                  width: self.view.frame.size.width,
                                                  height: self.view.frame.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.citiesListViewControllerWillDisappear()
    }
    
    
    
    
    // MARK: - IBActions
        
    @IBAction func goToSearchScreen() {
        let searchScreen = SearchScreenViewController()
        searchScreen.delegate = self
        self.navigationController?.pushViewController(searchScreen, animated: true)
    }
    
    // MARK: - Flow funcs

    private func addCitiesListTableView(frame: CGRect) {
        let citiesListTableView = UITableView(frame: frame)
        citiesListTableView.rowHeight = CityTableViewCell.cellHeight
        citiesListTableView.separatorStyle = .none
        
        citiesListTableView.dataSource = self
        citiesListTableView.delegate = self
        citiesListTableView.dragDelegate = self
        citiesListTableView.dropDelegate = self
        
        self.view.addSubview(citiesListTableView)
    }
    

}
