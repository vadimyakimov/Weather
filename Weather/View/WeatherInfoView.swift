import UIKit

class WeatherInfoView: UIView {
    
    // MARK: - Properties
        
    let viewModel: WeatherInfoViewModel
        
    private let verticalSpacing: CGFloat = 30
    
    private let currentWeatherView = CurrentWeatherView.instanceFromNib()
    private var hourlyForecastViews = [OneHourView](repeating: OneHourView(), count: 12)
    private var dailyForecastViews = [OneDayView](repeating: OneDayView(), count: 5)
            
    // MARK: - Initializers
    
    init(for city: City) {
        self.viewModel = WeatherInfoViewModel(city: city)
        super.init(frame: CGRect.zero)
        
        self.bindViewModel()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding functions
    
    func bindViewModel() {
        
        viewModel.currentWeather.bind { [unowned self] currentWeatherData in
            self.updateCurrentWeather(currentWeatherData)
        }
        
        viewModel.hourlyForecast.bind { [unowned self] hourlyForecastData in
            self.updateHourlyForecast(hourlyForecastData)
        }
        
        viewModel.dailyForecast.bind { [unowned self] dailyForecastData in
            self.updateDailyForecast(dailyForecastData)
        }
        
//            
//        
//        print(viewModel.city.currentWeather)
//        print(viewModel.currentWeather.value)
        
//        self.viewModel.isCurrentWeatherUpdating.bind { [unowned self] isUpdating in
//            if !isUpdating {
//                self.updateView(self.currentWeatherView)
//            }
//        }
//        
//        self.viewModel.isHourlyForecastUpdating.bind { [unowned self] isUpdating in
//            if !isUpdating {
//                self.updateView(self.hourlyForecastViews)
//            }
//        }
//        
//        self.viewModel.isDailyForecastUpdating.bind { [unowned self] isUpdating in
//            if !isUpdating {
//                self.updateView(self.dailyForecastViews)
//            }
//        }
    }
    
    // MARK: - Configure functions
    
    func configure() {
        self.frame.size.height += self.verticalSpacing / 2
        self.configureCurrentWearher()
        self.configureHourlyForecast()
        self.configureDailyForecast()
    }
    
    func refreshWeather() {
        self.currentWeatherView.startSkeleton(isDayTime: self.viewModel.isDayTime)
        let _ = self.hourlyForecastViews.map({ $0.startSkeleton() })
        let _ = self.dailyForecastViews.map({ $0.startSkeleton() })
        self.viewModel.refreshWeather()
    }
    
    private func configureCurrentWearher() {
               
        let top = self.frame.height
        let width = self.frame.width
        let currentWeatherViewSide = self.currentWeatherView.frame.width
        
        self.currentWeatherView.configure(isDayTime: self.viewModel.isDayTime)
        self.currentWeatherView.frame.origin = CGPoint(x: (width - currentWeatherViewSide) / 2, y: top)
        
        self.addSubview(self.currentWeatherView)
        
        self.frame.size.height += currentWeatherViewSide + self.verticalSpacing
        
        if self.viewModel.lastUpdated.currentWeather.timeIntervalSinceNow > -600 {
            self.updateCurrentWeather(self.viewModel.currentWeather.value)
        } else {
            self.viewModel.fetchCurrentWeather()
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
        
        
        if self.viewModel.lastUpdated.hourlyForecast.timeIntervalSinceNow > -600 {
            self.updateHourlyForecast(self.viewModel.hourlyForecast.value)
        } else {
            self.viewModel.fetchHourlyForecast()
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
        
        if self.viewModel.lastUpdated.dailyForecast.timeIntervalSinceNow > -600 {
            self.updateDailyForecast(self.viewModel.dailyForecast.value)
        } else {
            self.viewModel.fetchDailyForecast()
        }
    }
    
    // MARK: - UI data update functions
        
    private func updateCurrentWeather(_ currentWeather: CurrentWeather?) {
        
        guard let data = currentWeather else { return }
        
        self.currentWeatherView.configure(isDayTime: data.isDayTime,
                                          temperature: Int(data.temperatureCelsius),
                                          weatherText: data.weatherText)
        NetworkManager.shared.getImage(iconNumber: Int(data.weatherIcon)) { [unowned self] weatherIcon in
            self.currentWeatherView.setIcon(weatherIcon)
        }
    }
    
    private func updateHourlyForecast(_ hourlyForecast: [HourlyForecast]?) {
        
        guard let data = hourlyForecast,
              data.count == self.hourlyForecastViews.count else { return }
        
        for (index, view) in self.hourlyForecastViews.enumerated() {
            view.configure(time: data[index].forecastTime,
                           temperature: Int(data[index].temperatureCelsius),
                           weatherText: data[index].weatherText)
            NetworkManager.shared.getImage(iconNumber: Int(data[index].weatherIcon)) { weatherIcon in
                view.setIcon(weatherIcon)
            }
        }
    }
    
    private func updateDailyForecast(_ dailyForecast: [DailyForecast]?) {
        
        guard let data = dailyForecast,
              data.count == self.dailyForecastViews.count else { return }
        
        for (index, view) in self.dailyForecastViews.enumerated() {
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
