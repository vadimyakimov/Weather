//
//  SingleCityViewController.swift
//  Weather 2
//
//  Created by Вадим on 13.01.2022.
//

import UIKit
import CoreData

class CityViewController: UIViewController {
    
    // MARK: - Properties
    
//    var cityIndex: Int
//    var isDayTime: Bool
//    var nameLabel = UILabel()
//    let nameLabelFontSize: CGFloat = 60
//    let nameLabelMinimumFontSize: CGFloat = 30
    
    let city: City
    
    var weatherInfoView: WeatherInfoView
    let cityRefreshControl = UIRefreshControl()
    
    let frameRectangle: CGRect
        
    private var isConfigured = false
    
    weak var delegate: CityViewControllerDelegate?
    
    
    // MARK: - Lifecycle
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        if !isConfigured {
            self.configure()
        }
    }
    
    // MARK: - Initializers
    
    init(_ city: City, frame: CGRect) {
        self.city = city
        self.weatherInfoView = WeatherInfoView(for: city)
        self.frameRectangle = frame
        
        super.init(nibName: nil, bundle: nil)
        
        weatherInfoView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Flow funcs
    
    private func configure() {
        
//        let topBound: CGFloat = 90
        
//        let nameLabelHeight: CGFloat = 80
        
//        self.configureHeader(nameLabelHeight: nameLabelHeight)
        
        self.cityRefreshControl.addTarget(self, action: #selector(refreshWeatherInfo), for: .valueChanged)
        self.cityRefreshControl.tintColor = .white
        
        self.weatherInfoView.frame.size.width = self.view.frame.width
        self.weatherInfoView.configure()
                        
        let cityScrollView = UIScrollView()
        cityScrollView.delegate = self
        cityScrollView.frame = CGRect(x: self.frameRectangle.origin.x,
                                      y: self.frameRectangle.origin.y + self.view.safeAreaInsets.top,
                                      width: self.frameRectangle.width,
                                      height: self.frameRectangle.height - self.view.safeAreaInsets.top)
        cityScrollView.contentSize = weatherInfoView.frame.size
        cityScrollView.showsVerticalScrollIndicator = false
        
        cityScrollView.addSubview(weatherInfoView)
        cityScrollView.refreshControl = cityRefreshControl
        self.view.addSubview(cityScrollView)
        
        self.isConfigured = true
    }
    
    @IBAction func refreshWeatherInfo() {
        self.weatherInfoView.refreshWeather()
    }
    
    
//    private func configureHeader(nameLabelHeight: CGFloat) {
//                       
//        let screen = self.view.frame.size
//        
//        let horizontalOffsets: CGFloat = 20
////        let updateLabelWidth: CGFloat = 300
////        let updateLabelHeight: CGFloat = 30
//                        
//        self.nameLabel = UILabel(frame: CGRect(x: horizontalOffsets,
//                                               y: self.view.safeAreaInsets.top,
//                                               width: screen.width - (horizontalOffsets * 2),
//                                               height: nameLabelHeight))
//        self.nameLabel.textColor = .white
//        self.nameLabel.text = self.city.name
//        self.nameLabel.textAlignment = .center
//        self.nameLabel.font = UIFont.systemFont(ofSize: self.nameLabelFontSize, weight: .light)
//        nameLabel.layer.zPosition = 100
//        nameLabel.adjustsFontSizeToFitWidth = true
//        
//        self.view.addSubview(nameLabel)
//        
//        
////        if let lastUpdated = self.city.lastUpdated {
////            
////            let updateLabel = createLabel(x: screen.width - updateLabelWidth - horizontalOffsets,
////                                          y: 0,
////                                          width: updateLabelWidth,
////                                          height: updateLabelHeight,
////                                          text: updatedAt(date: lastUpdated),
////                                          color: .white,
////                                          align: .right)
////            self.cityScrollView.addSubview(updateLabel)
////        }
//        
//    }
    
    
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
