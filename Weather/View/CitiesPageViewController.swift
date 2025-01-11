//
//  CitiesPageViewController.swift
//  Weather
//
//  Created by Вадим on 03.12.2024.
//

import UIKit
import EMPageViewController
import CoreData

class CitiesPageViewController: EMPageViewController {
    
    // MARK: - Properties

    private let viewModel: CitiesPageViewModelProtocol

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    private let backgroundGradient = BackgroundGradient()

    private var nameLabel = UILabel()
    private var newNameLabel = UILabel()
    private let nameLabelHeight: CGFloat = 80
    private let nameLabelFontSize: CGFloat = 60
    private let nameLabelMinimumFontSize: CGFloat = 30
    private let horizontalOffset: CGFloat = 20

    private let pageControl = UIPageControl()
    private let pageControlHeight: CGFloat = 20
    private var previousPageControlIndex: Int?
        
    // MARK: - Lifecycle

    override func viewDidLoad() {
                
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        self.scrollView.contentInsetAdjustmentBehavior = .never

        self.addGradient()
        self.showCityViewController()
        
        self.configurePageControl()
        self.addNameLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        if let controller = self.selectedViewController as? CityViewController {
            self.configureNameLabel(self.nameLabel, text: controller.viewModel.cityName)
            self.configureNameLabel(self.newNameLabel)
        }
    }
    
    // MARK: - Initializers
    
    init(viewModel: CitiesPageViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.pageControl.removeTarget(self, action: nil, for: .allEvents)
    }
    
    // MARK: - IBActions

    @IBAction private func listButtonPressed() {
        let list = CitiesListViewController(viewModel: self.viewModel.createCitiesListViewModel())
        list.delegate = self
        self.navigationController?.pushViewController(list, animated: true)
    }

    @IBAction private func pageControlValueChanged(_ sender: Any) {
        guard let pageControl = sender as? UIPageControl else { return }

        if pageControl.isSelected {
            return
        } else {
            self.pageControl(didUpdate: pageControl)
        }
    }

    @IBAction private func pageControlTouchDown(_ sender: Any) {
        guard let pageControl = sender as? UIPageControl else { return }
        pageControl.isSelected = true
        self.previousPageControlIndex = pageControl.currentPage
    }

    @IBAction private func pageControlTouchUp(_ sender: Any) {
        guard let pageControl = sender as? UIPageControl else { return }
        pageControl.isSelected = false
        self.pageControl(didUpdate: pageControl)
    }
    
    // MARK: - View Controllers Management

    func showCityViewController(withIndex index: Int = 0, direction: EMPageViewControllerNavigationDirection = .forward) {
        guard let controller = self.cityViewController(withIndex: index) else { return }

        self.selectViewController(controller, direction: direction, animated: true, completion: nil)
        self.changeGradientColor(for: controller)
    }

    private func cityViewController(withIndex i: Int) -> CityViewController? {
        
        var index = i
        let citiesCount = self.viewModel.citiesCount
        
        if !(0..<citiesCount ~= index) {
            if citiesCount > 3 {
                index = (index % citiesCount + citiesCount) % citiesCount
            } else {
                return nil
            }
        }

        let cityViewController = CityViewController(viewModel: self.viewModel.createCityViewModel(withIndex: index),
                                                    topOffset: self.nameLabelHeight + self.pageControlHeight)
        
        cityViewController.delegate = self
        cityViewController.changeGradientColor = { [unowned self] controller in
            self.changeGradientColor(for: controller)
        }        
        return cityViewController
    }
    
//  MARK: - Page Control
        
    private func configurePageControl() {
        
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.pageControl)
                
        NSLayoutConstraint.activate([
            self.pageControl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.pageControl.heightAnchor.constraint(equalToConstant: self.pageControlHeight),
            self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
                  
        self.pageControl.hidesForSinglePage = true
        
        self.updatePageControl()

        self.pageControl.addTarget(self, action: #selector(self.pageControlValueChanged(_:)), for: .valueChanged)
        self.pageControl.addTarget(self, action: #selector(self.pageControlTouchDown(_:)), for: .touchDown)
        self.pageControl.addTarget(self, action: #selector(self.pageControlTouchUp(_:)), for: [.touchUpInside])
    }

    private func updatePageControl(index: Int? = nil) {
        
        self.pageControl.numberOfPages = self.viewModel.citiesCount

        if let index {
            self.pageControl.currentPage = index
            self.pageControl.setNeedsLayout()
        }
    }

    private func pageControl(didUpdate pageControl: UIPageControl) {
        guard let previousPageControlIndex = self.previousPageControlIndex,
              pageControl.currentPage != previousPageControlIndex,
              !pageControl.isSelected else { return }

        if pageControl.currentPage > previousPageControlIndex {
            showCityViewController(withIndex: pageControl.currentPage, direction: .forward)
        } else {
            showCityViewController(withIndex: pageControl.currentPage, direction: .reverse)
        }
    }

    // MARK: - Name Label

    private func addNameLabel() {
        
        self.newNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.newNameLabel)
        self.view.addSubview(self.nameLabel)
        
        NSLayoutConstraint.activate([
            self.nameLabel.topAnchor.constraint(equalTo: self.pageControl.bottomAnchor),
            self.nameLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,
                                                    constant: self.horizontalOffset),
            self.nameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor,
                                                  constant: -self.horizontalOffset * 2),
            self.nameLabel.heightAnchor.constraint(equalToConstant: self.nameLabelHeight),
            
            
            self.newNameLabel.topAnchor.constraint(equalTo: self.pageControl.bottomAnchor),
            self.newNameLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,
                                                       constant: self.horizontalOffset),
            self.newNameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor,
                                                     constant: -self.horizontalOffset * 2),
            self.newNameLabel.heightAnchor.constraint(equalToConstant: self.nameLabelHeight),
        ])
        
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(self.listButtonPressed))
        self.nameLabel.addGestureRecognizer(recognizer)
    }

    private func configureNameLabel(_ nameLabel: UILabel, text: String? = nil) {
        nameLabel.text = text
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: self.nameLabelFontSize, weight: .light)
        nameLabel.layer.zPosition = 100
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.isUserInteractionEnabled = true
    }

    // MARK: - Background Gradient

    private func addGradient() {
        self.backgroundGradient.frame = self.view.bounds
        self.view.layer.insertSublayer(backgroundGradient, at: 0)
    }

    private func changeGradientColor(for controller: CityViewController, forceChange: Bool = false) {
        
        guard forceChange || self.selectedViewController == controller else { return }
                        
        self.backgroundGradient.isDayTime = controller.viewModel.isDayTime
    }
}


// MARK: -
// MARK: - EM Page View Controller Data Source

extension CitiesPageViewController: EMPageViewControllerDataSource {
    
    func em_pageViewController(_ pageViewController: EMPageViewController,
                               viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? CityViewController else { return nil }
        let index = controller.viewModel.cityId
        return self.cityViewController(withIndex: index - 1)
    }

    func em_pageViewController(_ pageViewController: EMPageViewController,
                               viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? CityViewController else { return nil }
        let index = controller.viewModel.cityId
        return self.cityViewController(withIndex: index + 1)
    }
}

// MARK: - EM Page View Controller Delegate

extension CitiesPageViewController: EMPageViewControllerDelegate {
    
    func em_pageViewController(_ pageViewController: EMPageViewController,
                               isScrollingFrom startingViewController: UIViewController,
                               destinationViewController: UIViewController, progress: CGFloat) {
        
        guard let destinationViewController = destinationViewController as? CityViewController,
              let startingViewController = startingViewController as? CityViewController else { return }
        
        /// Changing backgroung depending on which view controller takes the most part of the screen
        if abs(progress) > 0.5 {
            self.changeGradientColor(for: destinationViewController, forceChange: true)
        } else {
            self.changeGradientColor(for: startingViewController, forceChange: true)
        }
        
        /// Changing UILabel with city name with push animation

        self.nameLabel.text = startingViewController.viewModel.cityName
        self.newNameLabel.text = destinationViewController.viewModel.cityName
                        
        let nameLabelLeadingConstraint = self.view.constraints.filter({     // Leading constrain
            guard let firstItem = $0.firstItem as? NSObject else { return false }
            return firstItem == self.nameLabel && $0.firstAttribute == .leading
        }).first
        
        let newNameLabelLeadingConstraint = self.view.constraints.filter({  // Leading constrain
            guard let firstItem = $0.firstItem as? NSObject else { return false }
            return firstItem == self.newNameLabel && $0.firstAttribute == .leading
        }).first
                
        switch abs(progress) {
        case 0:
            newNameLabelLeadingConstraint?.constant = self.horizontalOffset + self.view.frame.width
        case 0..<1:
            
            /// Graphs for push animation
            let oldLabelGraph = -pow(progress, 3)
            let newLabelGraph = (progress / abs(progress)) - (abs(pow(progress, 5)) / progress)
            
            nameLabelLeadingConstraint?.constant = self.horizontalOffset + (self.view.frame.width * oldLabelGraph)
            newNameLabelLeadingConstraint?.constant = self.horizontalOffset + (self.view.frame.width * newLabelGraph)
            
            let oldLabelOpacityGraph = -pow(progress, 2) + 1
            let newLabelOpacityGraph = pow(progress, 2)

            self.nameLabel.layer.opacity = Float(oldLabelOpacityGraph)
            self.newNameLabel.layer.opacity = Float(newLabelOpacityGraph)
        case 1:
            self.nameLabel.text = destinationViewController.viewModel.cityName
            nameLabelLeadingConstraint?.constant = self.horizontalOffset
            self.nameLabel.layer.opacity = 1

            self.newNameLabel.text = nil
            newNameLabelLeadingConstraint?.constant = self.view.frame.width
            self.newNameLabel.layer.opacity = 0
        default:
            break
        }

    }

    func em_pageViewController(_ pageViewController: EMPageViewController,
                               didFinishScrollingFrom startingViewController: UIViewController?,
                               destinationViewController: UIViewController,
                               transitionSuccessful: Bool) {
        guard transitionSuccessful,
              let controller = destinationViewController as? CityViewController else { return }
         let index = controller.viewModel.cityId
        
        self.updatePageControl(index: index)
        
    }
}

// MARK: - City View Controller Delegate

extension CitiesPageViewController: CityViewControllerDelegate {

    func cityViewController(scrollViewDidScroll scrollView: UIScrollView) {
        let fontSize = self.nameLabelFontSize - scrollView.contentOffset.y
        if fontSize < self.nameLabelFontSize * 2 &&
            fontSize > self.nameLabelMinimumFontSize {
            self.nameLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .light)
            self.newNameLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .light)
        }
    }
}

// MARK: - Cities List Screen Delegate

extension CitiesPageViewController: CitiesListViewControllerDelegate {
    
    func citiesListViewController(didSelectRowAt indexPath: IndexPath) {
        self.showCityViewController(withIndex: indexPath.row)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func citiesListViewControllerDidChangeContent() {
        let controller = self.selectedViewController as? CityViewController
        guard let cityId = controller?.viewModel.cityId else { return }

        /// If a city has been moved, index changes to the city's new position;
        /// if the city has been deleted, all following cities decrement their index,
        /// therefore the next city has the same index as the deleted one.
        let index = min(cityId, self.viewModel.citiesCount - 1)

        self.showCityViewController(withIndex: index)
    }
}
