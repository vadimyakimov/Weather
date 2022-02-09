//
//  SingleCityViewController.swift
//  Weather 2
//
//  Created by Вадим on 13.01.2022.
//

import UIKit

class CityViewController: UIViewController {
    
    // MARK: - Properties
    
//    var cityIndex: Int
//    var isDayTime: Bool
    var nameLabel = UILabel()
    let nameLabelFontSize: CGFloat = 60
    let nameLabelMinimumFontSize: CGFloat = 30
    
    var city: City
    
//    private var cityScrollView = UIScrollView()
    
    private var isConfigured = false
    
    weak var delegate: CityViewControllerDelegate?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.cityViewController(willAppear: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        if !self.isConfigured {
            self.configure()
        }
    }
    
    // MARK: - Initializers
    
    init(_ city: City) {
                
//        var i = index
//
//        let citiesCount = Manager.shared.citiesArray.count
//
//        if i < 0 {
//            i += citiesCount
//        } else if i >= citiesCount {
//            i -= citiesCount
//        }
        
        self.city = city
//        self.cityIndex = i
//        self.isDayTime = self.city.currentWeather?.isDayTime ?? true
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Flow funcs
    
    
    private func configure() {
        
        let topBound: CGFloat = 90
        
        self.configureHeader(startAt: topBound)
        
        let weatherInfoView = WeatherInfoView(for: city, width: self.view.frame.width)
                
        let cityScrollView = UIScrollView()
        cityScrollView.delegate = self
        cityScrollView.frame = CGRect(x: 0,
                                      y: self.view.safeAreaInsets.top + topBound,
                                      width: self.view.frame.size.width,
                                      height: self.view.frame.size.height - self.view.safeAreaInsets.top - topBound)
        cityScrollView.contentSize = CGSize(width: self.view.frame.width,
                                                 height: weatherInfoView.frame.height)
        cityScrollView.showsVerticalScrollIndicator = false
//        self.addFade(to: cityScrollView)
        
        cityScrollView.addSubview(weatherInfoView)
        self.view.addSubview(cityScrollView)
        
        self.isConfigured = true
    }
    
    
    private func configureHeader(startAt topBound: CGFloat) {
                       
        let screen = self.view.frame.size
        
        let horizontalOffsets: CGFloat = 20
        let nameLabelHeight: CGFloat = 80
//        let updateLabelWidth: CGFloat = 300
//        let updateLabelHeight: CGFloat = 30
                        
        self.nameLabel = UILabel(frame: CGRect(x: horizontalOffsets,
                                               y: self.view.safeAreaInsets.top + (topBound - nameLabelHeight),
                                               width: screen.width - (horizontalOffsets * 2),
                                               height: nameLabelHeight))
        self.nameLabel.textColor = .white
        self.nameLabel.text = self.city.name
        self.nameLabel.textAlignment = .center
        self.nameLabel.font = UIFont.systemFont(ofSize: self.nameLabelFontSize, weight: .light)
        

        nameLabel.layer.zPosition = 100
        nameLabel.adjustsFontSizeToFitWidth = true
        
        self.view.addSubview(nameLabel)
        
//        if let lastUpdated = self.city.lastUpdated {
//            
//            let updateLabel = createLabel(x: screen.width - updateLabelWidth - horizontalOffsets,
//                                          y: 0,
//                                          width: updateLabelWidth,
//                                          height: updateLabelHeight,
//                                          text: updatedAt(date: lastUpdated),
//                                          color: .white,
//                                          align: .right)
//            self.cityScrollView.addSubview(updateLabel)
//        }
        
    }
    
    func addFade(to scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
        let alpha:CGFloat = (scrollViewHeight >= scrollContentSizeHeight || scrollOffset <= 0) ? 1 : 0
        
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 0.1)
        gradient.frame = CGRect(x: 0, y: 0,
                                width: scrollView.frame.size.width,
                                height: scrollView.frame.size.height)
        gradient.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: alpha).cgColor,
                           UIColor.black.cgColor]
            
        let mask = CALayer()
        mask.frame = scrollView.bounds
        mask.addSublayer(gradient)
        
        scrollView.layer.mask = mask
    }
    
//    private func updatedAt(date: Date) -> String {
//        let interval = date.timeIntervalSinceNow
//        let formatted = DateFormatter()
//        
//        switch interval {
//        case -60 ... 0:
//            return "Updated just now"
//        case -300 ... -61:
//            return "Updated recently"
//        case -86400 ... -301:
//            formatted.dateFormat = "HH:mm"
//            return "Updated at \(formatted.string(from: date))"
//        default:
//            formatted.dateFormat = "MMM d"
//            return "Updated at \(formatted.string(from: date))"
//        }
//    }
    
    
    
}
