//
//  SingleCityViewController.swift
//  Weather 2
//
//  Created by Вадим on 13.01.2022.
//

import UIKit

class CityViewController: UIViewController {
    
    // MARK: - Properties
    
    var cityIndex: Int
    var isDayTime: Bool
    var nameLabel = UILabel()
    let nameLabelFontSize: CGFloat = 60
    let nameLabelMinimumFontSize: CGFloat = 30
    
    private var city: City
    private var cityScrollView = UIScrollView()
    private var isConfigured = false
    
    weak var delegate: CityViewControllerDelegate?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.isConfigured {
            self.configure()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        delegate?.cityViewController(didAppear: self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    // MARK: - Initializers
    
    init(index: Int) {
        var i = index
        
        let cities = Manager.shared.citiesArray
        
        if i < 0 {
            i += cities.count + 1
        } else if i >= cities.count {
            i -= cities.count
        }
        
        self.city = Manager.shared.citiesArray[i]
        self.cityIndex = i        
        self.isDayTime = self.city.currentWeather?.isDayTime ?? true
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Flow funcs
    
    func setScrollViewFade() {
        let scrollViewHeight = self.cityScrollView.frame.size.height
        let scrollContentSizeHeight = self.cityScrollView.contentSize.height
        let scrollOffset = self.cityScrollView.contentOffset.y
        
        let alpha:CGFloat = (scrollViewHeight >= scrollContentSizeHeight || scrollOffset <= 0) ? 1 : 0
        
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 0.1)
        gradient.frame = CGRect(x: 0, y: 0,
                                width: self.cityScrollView.frame.size.width,
                                height: self.cityScrollView.frame.size.height)
        gradient.colors = [UIColor(red: 0, green: 0, blue: 0, alpha: alpha).cgColor,
                           UIColor.black.cgColor]
        
        let mask = CALayer()
        mask.frame = self.cityScrollView.bounds
        mask.addSublayer(gradient)
        
        self.cityScrollView.layer.mask = mask
    }
    
    private func configure() {
        
        let topBound: CGFloat = 90
        var contentHeight: CGFloat = 0
        
        
        self.cityScrollView.frame = CGRect(x: 0,
                                         y: self.view.safeAreaInsets.top + topBound,
                                         width: self.view.frame.size.width,
                                         height: self.view.frame.size.height - self.view.safeAreaInsets.top - topBound)
        self.cityScrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(self.cityScrollView)
        self.cityScrollView.delegate = self
        
        self.setScrollViewFade()
        
        
        contentHeight += self.configureHeader(startAt: topBound)
        
        if let lastUpdated = self.city.lastUpdated, lastUpdated.timeIntervalSinceNow > -600  {
            contentHeight += self.configureCurrentWearher(startAt: contentHeight)
            contentHeight += self.configureHourlyForecast(startAt: contentHeight)
            contentHeight += self.configureDailyForecast(startAt: contentHeight)
        } else {
            Manager.shared.getCurrentWeather(for: self.cityIndex) {
                contentHeight += self.configureCurrentWearher(startAt: contentHeight)
            }
            Manager.shared.getHourlyForecast(for: self.cityIndex) {
                contentHeight += self.configureHourlyForecast(startAt: contentHeight)
            }
            Manager.shared.getDailyForecast(for: self.cityIndex) {
                contentHeight += self.configureDailyForecast(startAt: contentHeight)
            }
        }
        DispatchQueue.main.async {
            self.cityScrollView.contentSize = CGSize(width: self.view.frame.size.width,
                                                 height: contentHeight)
        }
        
        self.isConfigured = true
    }
    
    private func configureHeader(startAt topBound: CGFloat) -> CGFloat {
                       
        let screen = self.view.frame.size
        
        let horizontalOffsets: CGFloat = 20
        let nameLabelHeight: CGFloat = 80
        let updateLabelWidth: CGFloat = 300
        let updateLabelHeight: CGFloat = 30
                        
        self.nameLabel = UILabel(frame: CGRect(x: horizontalOffsets,
                                               y: self.view.safeAreaInsets.top + (topBound - nameLabelHeight),
                                               width: screen.width - (horizontalOffsets * 2),
                                               height: nameLabelHeight))
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: self.nameLabelFontSize, weight: .light)
        nameLabel.text = self.city.name
        nameLabel.textAlignment = .center
        nameLabel.layer.zPosition = 100
        nameLabel.adjustsFontSizeToFitWidth = true
        self.view.addSubview(nameLabel)
        
        if let lastUpdated = self.city.lastUpdated {
            let updateLabel = UILabel(frame: CGRect(x: screen.width - updateLabelWidth - horizontalOffsets,
                                                    y: 0,
                                                    width: updateLabelWidth,
                                                    height: updateLabelHeight))
            updateLabel.textColor = .white
            updateLabel.text = updatedAt(date: lastUpdated)
            updateLabel.textAlignment = .right
            self.cityScrollView.addSubview(updateLabel)
        }
        
        return updateLabelHeight
        
    }
    
    private func configureCurrentWearher(startAt topBound: CGFloat) -> CGFloat {
        
        guard let currentWeather = self.city.currentWeather else { return 0 }
        
        let screen = self.view.frame
        let verticalOffsets: CGFloat = 30
//        var weatherIcon: UIImage
        
        let currentWeatherView = CurrentWeatherView.instanceFromNib()
        let currentWeatherViewSide = currentWeatherView.frame.width
        
        Manager.shared.getImage(iconNumber: currentWeather.weatherIcon) { weatherIcon in
            currentWeatherView.setIcon(weatherIcon)
        }
        
        currentWeatherView.configure(isDayTime: currentWeather.isDayTime,
                                     temperature: currentWeather.temperatureCelsius,
                                     weatherText: currentWeather.weatherText)
        currentWeatherView.frame.origin = CGPoint(x: (screen.width - currentWeatherViewSide) / 2,
                                                  y: topBound + verticalOffsets)
        self.cityScrollView.addSubview(currentWeatherView)
           
        
        return currentWeatherViewSide + (verticalOffsets * 2)
    }
    
    private func configureHourlyForecast(startAt topBound: CGFloat) -> CGFloat {
        guard let hourlyForecast = self.city.hourlyForecast else { return 0 }
        
        let screen = self.view.frame
        let offsetBetween: CGFloat = 20
        let oneHourViewSize = OneHourView.instanceFromNib().frame.size
        var contentWidth = offsetBetween
        
        
        let hourlyScrollView = UIScrollView(frame: CGRect(x: 0,
                                                          y: topBound,
                                                          width: screen.width,
                                                          height: oneHourViewSize.height))
        hourlyScrollView.showsHorizontalScrollIndicator = false
        self.cityScrollView.addSubview(hourlyScrollView)

        
        for element in hourlyForecast {
            
            let oneHourView = OneHourView.instanceFromNib()
            
            Manager.shared.getImage(iconNumber: element.weatherIcon) { weatherIcon in
                oneHourView.setIcon(weatherIcon)
            }
            
            oneHourView.configure(time: element.forecastTime,
                                  temperature: element.temperatureCelsius,
                                  weatherText: element.weatherText)
            oneHourView.frame.origin = CGPoint(x: contentWidth, y: 0)
            hourlyScrollView.addSubview(oneHourView)
            contentWidth += oneHourViewSize.width + offsetBetween

        }
        
        hourlyScrollView.contentSize = CGSize(width: contentWidth,
                                              height: oneHourViewSize.height)
        
        return oneHourViewSize.height
    }
    
    private func configureDailyForecast(startAt topBound: CGFloat) -> CGFloat {
        guard let dailyForecast = self.city.dailyForecast else { return 0 }
        
        let screen = self.view.frame
        
        let horizontalOffsets: CGFloat = 20
        let verticalOffsets: CGFloat = 30
        let dailyViewCornerRadius: CGFloat = 20
        
        let oneDayViewHeight = OneDayView.instanceFronNib().frame.height
        
        
        let dailyView = UIView(frame: CGRect(x: horizontalOffsets,
                                             y: topBound + verticalOffsets,
                                             width: screen.width - (horizontalOffsets * 2),
                                             height: oneDayViewHeight * CGFloat(dailyForecast.count)))
        if #available(iOS 13.0, *) {
            dailyView.backgroundColor = .systemBackground
        } else {
            dailyView.backgroundColor = .white
        }
        dailyView.layer.cornerRadius = dailyViewCornerRadius
        self.cityScrollView.addSubview(dailyView)
        
        for (index, element) in dailyForecast.enumerated() {
            
            let oneDayView = OneDayView.instanceFronNib()
            Manager.shared.getImage(iconNumber: element.dayWeather.weatherIcon) { dayIcon in
                oneDayView.setDayIcon(dayIcon)
            }
            
            Manager.shared.getImage(iconNumber: element.nightWeather.weatherIcon) { nightIcon in
                oneDayView.setNightIcon(nightIcon)
            }
                
            oneDayView.configure(date: element.forecastDate,
                                 dayTemperature: element.dayWeather.temperatureCelsius,
                                 nightTemperature: element.nightWeather.temperatureCelsius)
            oneDayView.frame.origin = CGPoint(x: 0, y: Int(oneDayViewHeight) * index)
            oneDayView.frame.size.width = dailyView.frame.width
            dailyView.addSubview(oneDayView)
        }
        
        return (oneDayViewHeight * CGFloat(dailyForecast.count)) + (verticalOffsets * 2)
    }
    
    private func updatedAt(date: Date) -> String {
        let interval = date.timeIntervalSinceNow
        let formatted = DateFormatter()
        
        switch interval {
        case -60 ... 0:
            return "Updated just now"
        case -300 ... -61:
            return "Updated recently"
        case -86400 ... -301:
            formatted.dateFormat = "HH:mm"
            return "Updated at \(formatted.string(from: date))"
        default:
            formatted.dateFormat = "MMM d"
            return "Updated at \(formatted.string(from: date))"
        }
    }
    
    
}
