import UIKit
import CoreData

class CitiesListViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: (CitiesListViewControllerDelegate & SearchScreenViewControllerDelegate)?
    
    var fetchedResultsController: NSFetchedResultsController<City>
    
    var citiesArray: [City] {
        get {
            return self.fetchedResultsController.fetchedObjects ?? []
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
                
        super.viewDidLoad()
              
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search,
                                           target: self,
                                           action: #selector(goToSearchScreen))
        self.navigationItem.rightBarButtonItem = searchButton
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()        
        self.addCitiesListTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.citiesListViewControllerWillDisappear()
    }
    
    // MARK: - Initializers
    
    init(fetchedResultsController: NSFetchedResultsController<City>) {
        self.fetchedResultsController = fetchedResultsController
        super.init(nibName: nil, bundle: nil)
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
