import UIKit

class WeatherInfoView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: WeatherInfoViewDelegate?
    
    private let city: City
    
    private let verticalSpacing: CGFloat = 30
    
    private let currentWeatherView = CurrentWeatherView.instanceFromNib()
    private var hourlyForecastViews = [OneHourView](repeating: OneHourView(), count: 12)
    private var dailyForecastViews = [OneDayView](repeating: OneDayView(), count: 5)
            
    // MARK: - Initializers
    
    init(for city: City) {
        self.city = city
        super.init(frame: CGRect.zero)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure functions
    
    func configure() {
        self.frame.size.height += self.verticalSpacing / 2
        self.configureCurrentWearher()
        self.configureHourlyForecast()
        self.configureDailyForecast()
    }
    
    func refreshWeather() {
        let tasks = DispatchGroup()
        
        tasks.enter()
        self.currentWeatherView.startSkeleton(isDayTime: city.currentWeather?.isDayTime)
        NetworkManager.shared.getCurrentWeather(for: self.city) { currentWeather in
            if let currentWeather = currentWeather {
                self.updateData(currentWeather)
            }
            self.updateView(self.currentWeatherView)
            tasks.leave()
        }
        
        tasks.enter()
        let _ = self.hourlyForecastViews.map({ $0.startSkeleton() })
        NetworkManager.shared.getHourlyForecast(for: self.city) { dailyForecast in
            if let dailyForecast = dailyForecast {
                self.updateData(data: dailyForecast)
            }
            self.updateView(self.dailyForecastViews)
            tasks.leave()
        }

        tasks.enter()
        let _ = self.dailyForecastViews.map({ $0.startSkeleton() })
        NetworkManager.shared.getDailyForecast(for: self.city) { hourlyForecast in
            if let hourlyForecast = hourlyForecast {
                self.updateData(data: hourlyForecast)
            }
            self.updateView(self.hourlyForecastViews)
            tasks.leave()
        }
        
        tasks.notify(queue: .main) {
            self.delegate?.weatherInfoView(didUpdateWeatherInfoFor: self.city)
        }
    }
    
    private func configureCurrentWearher() {
               
        let top = self.frame.height
        let width = self.frame.width
        let currentWeatherViewSide = self.currentWeatherView.frame.width
        
        self.currentWeatherView.configure(isDayTime: self.city.currentWeather?.isDayTime)
        self.currentWeatherView.frame.origin = CGPoint(x: (width - currentWeatherViewSide) / 2, y: top)
        
        self.addSubview(self.currentWeatherView)
        
        self.frame.size.height += currentWeatherViewSide + self.verticalSpacing
        
        if self.city.lastUpdated.currentWeather.timeIntervalSinceNow > -600 {
            self.updateView(self.currentWeatherView)
        } else {
            NetworkManager.shared.getCurrentWeather(for: self.city) { currentWeather in
                if let currentWeather = currentWeather {
                    self.updateData(currentWeather)
                }
                self.updateView(self.currentWeatherView)
            }
        }
        
    }
    
    private func configureHourlyForecast() {
        
        let top = self.frame.height
        let width = self.frame.width
        
        let offsetBetween: CGFloat = 20
        let oneHourViewSize = OneHourView.instanceFromNib().frame.size
        var contentWidth = offsetBetween
        
        
        let hourlyScrollView = UIScrollView(frame: CGRect(x: 0,
                                                          y: top,
                                                          width: width,
                                                          height: oneHourViewSize.height))
        hourlyScrollView.showsHorizontalScrollIndicator = false
        self.addSubview(hourlyScrollView)
        
        
        for index in 0..<self.hourlyForecastViews.count {
            let oneHourView = OneHourView.instanceFromNib()
            oneHourView.configure()
            oneHourView.frame.origin = CGPoint(x: contentWidth, y: 0)
            hourlyScrollView.addSubview(oneHourView)
            
            self.hourlyForecastViews[index] = oneHourView
            
            contentWidth += oneHourViewSize.width + offsetBetween            
        }
        
        hourlyScrollView.contentSize.width = contentWidth
        
        self.frame.size.height += hourlyScrollView.frame.height + self.verticalSpacing
        
        
        if self.city.lastUpdated.hourlyForecast.timeIntervalSinceNow > -600 {
            self.updateView(self.hourlyForecastViews)
        } else {
            NetworkManager.shared.getHourlyForecast(for: self.city) { hourlyForecast in
                if let hourlyForecast = hourlyForecast {
                    self.updateData(data: hourlyForecast)
                }
                self.updateView(self.hourlyForecastViews)
            }
        }
        
    }
    
    private func configureDailyForecast() {
        
        let top = self.frame.height
        let width = self.frame.width
        
        let horizontalOffset: CGFloat = 20
        let dailyViewCornerRadius: CGFloat = 20
        let oneDayViewHeight = OneDayView.instanceFronNib().frame.height
        
        let dailyView = UIView(frame: CGRect(x: horizontalOffset,
                                             y: top,
                                             width: width - (horizontalOffset * 2),
                                             height: oneDayViewHeight * CGFloat(self.dailyForecastViews.count)))
        dailyView.clipsToBounds = true
        dailyView.layer.cornerRadius = dailyViewCornerRadius
        self.addSubview(dailyView)
        
        for index in 0..<self.dailyForecastViews.count {
            let oneDayView = OneDayView.instanceFronNib()
            oneDayView.configure()
            oneDayView.frame.origin = CGPoint(x: 0, y: oneDayViewHeight * CGFloat(index))
            oneDayView.frame.size.width = dailyView.frame.width
            self.dailyForecastViews[index] = oneDayView
            dailyView.addSubview(oneDayView)
        }
        
        self.frame.size.height += dailyView.frame.height + self.verticalSpacing
        
        if self.city.lastUpdated.dailyForecast.timeIntervalSinceNow > -600 {
            self.updateView(self.dailyForecastViews)
        } else {
            NetworkManager.shared.getDailyForecast(for: self.city) { dailyForecast in
                if let dailyForecast = dailyForecast {
                    self.updateData(data: dailyForecast)
                }
                self.updateView(self.dailyForecastViews)
            }
        }
    }
    
    // MARK: - View's data update functions
        
    private func updateData(_ data: CurrentWeather) {
        
        self.city.currentWeather = data
        self.city.lastUpdated.currentWeather = Date()
        self.delegate?.weatherInfoView(didUpdateCurrentWeatherFor: self.city)
    }
    
    private func updateData(data: [HourlyForecast]) {
        
        self.city.hourlyForecast = NSOrderedSet(array: data)
        self.city.lastUpdated.hourlyForecast = Date()
        self.delegate?.weatherInfoView(didUpdateHourlyForecastFor: self.city)
    }
    
    private func updateData(data: [DailyForecast]) {
        
        self.city.dailyForecast = NSOrderedSet(array: data)
        self.city.lastUpdated.dailyForecast = Date()
        self.delegate?.weatherInfoView(didUpdateDailyForecastFor: self.city)
    }
    
    private func updateView(_ view: CurrentWeatherView) {
        
        guard let data = self.city.currentWeather else { return }
        
        view.configure(isDayTime: data.isDayTime,
                       temperature: Int(data.temperatureCelsius),
                       weatherText: data.weatherText)
        NetworkManager.shared.getImage(iconNumber: Int(data.weatherIcon)) { weatherIcon in
            view.setIcon(weatherIcon)
        }
    }
    
    private func updateView(_ views: [OneHourView]) {
        
        guard let data = self.city.hourlyForecast?.array as? [HourlyForecast],
                data.count == views.count else { return }
        
        for (index, view) in views.enumerated() {
            view.configure(time: data[index].forecastTime,
                           temperature: Int(data[index].temperatureCelsius),
                           weatherText: data[index].weatherText)
            NetworkManager.shared.getImage(iconNumber: Int(data[index].weatherIcon)) { weatherIcon in
                view.setIcon(weatherIcon)
            }
        }
    }
    
    private func updateView(_ views: [OneDayView]) {
        
        guard let data = self.city.dailyForecast?.array as? [DailyForecast],
                data.count == views.count else { return }
        
        for (index, view) in views.enumerated() {
            view.configure(date: data[index].forecastDate,
                           dayTemperature: Int(data[index].dayWeather.temperatureCelsius),
                           nightTemperature: Int(data[index].nightWeather.temperatureCelsius))
            NetworkManager.shared.getImage(iconNumber: Int(data[index].dayWeather.weatherIcon)) { dayIcon in
                view.setDayIcon(dayIcon)
            }
            NetworkManager.shared.getImage(iconNumber: Int(data[index].nightWeather.weatherIcon)) { nightIcon in
                view.setNightIcon(nightIcon)
            }
        }
    }
    
}
