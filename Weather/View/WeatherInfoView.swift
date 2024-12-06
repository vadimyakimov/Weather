import UIKit

class WeatherInfoView: UIView {
    
    // MARK: - Properties
        
    let viewModel: WeatherInfoViewModel
    
//    var isConfigured = false
    
    let cityRefreshControl = UIRefreshControl()
    
    private let verticalSpacing: CGFloat = 30
    private let innerOffset: CGFloat = 20
        
    private let currentWeatherView = CurrentWeatherView.instanceFromNib()
    
    private let hourlyForecastContainer: HourlyForecastView
    private let dailyForecastContainer: DailyForecastView
            
    // MARK: - Initializers
    
    init(for city: City) {
        self.viewModel = WeatherInfoViewModel(city: city)
        self.hourlyForecastContainer = HourlyForecastView(verticalSpacing: self.verticalSpacing, innerOffset: self.innerOffset)
        self.dailyForecastContainer = DailyForecastView(verticalSpacing: self.verticalSpacing)
        super.init(frame: .zero)
        
        self.bindViewModel()
    
//        if !self.isConfigured {
            self.configure()
//        }
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
            self.hourlyForecastContainer.updateForecast(hourlyForecastData)
        }
        
        viewModel.dailyForecast.bind { [unowned self] dailyForecastData in
            self.dailyForecastContainer.updateForecast(dailyForecastData)
        }
        
    }
    
    // MARK: - Configure functions
    
    func configure() {
        self.frame.size.height += self.verticalSpacing / 2
//        self.configureRefreshControl()
        self.configureCurrentWearher()
        self.configureHourlyForecast()
        self.configureDailyForecast()
    }
    
//    private func configureRefreshControl() {
//
////        self.cityRefreshControl.addTarget(self, action: #selector(refreshWeatherInfo), for: .valueChanged)
////        self.cityRefreshControl.tintColor = .white
//
////        self.weatherInfoView.frame.size.width = self.view.frame.width
//        
//
////        let cityScrollView = UIScrollView()
////        cityScrollView.delegate = self
////        cityScrollView.frame = CGRect(x: self.frameRectangle.origin.x,
////                                      y: self.frameRectangle.origin.y + self.view.safeAreaInsets.top,
////                                      width: self.frameRectangle.width,
////                                      height: self.frameRectangle.height - self.view.safeAreaInsets.top)
////        cityScrollView.contentSize = self.weatherInfoView.frame.size
////        cityScrollView.showsVerticalScrollIndicator = false
////
////        cityScrollView.addSubview(self.weatherInfoView)
////        cityScrollView.refreshControl = cityRefreshControl
////        self.view.addSubview(cityScrollView)
//
//        self.isConfigured = true
//    }
    
    func refreshWeather() {
        self.currentWeatherView.startSkeleton(isDayTime: self.viewModel.isDayTime)
        self.hourlyForecastContainer.startSkeleton()
        self.dailyForecastContainer.startSkeleton()
        self.viewModel.refreshWeather(isForcedUpdate: true)
    }
    
    private func configureCurrentWearher() {
        
        let view = self.currentWeatherView
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: self.verticalSpacing / 2),
            view.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            view.widthAnchor.constraint(equalToConstant: self.currentWeatherView.frame.width),
            view.heightAnchor.constraint(equalToConstant: self.currentWeatherView.frame.height),
        ])
        
        
        view.configure(isDayTime: self.viewModel.isDayTime) //?????
        
        
//        let currentWeatherViewSide = self.currentWeatherView.frame.width
//        self.frame.size.height += currentWeatherViewSide + self.verticalSpacing
        
        print("CurrentWearher \(view.hasAmbiguousLayout)")
        
    }
    
    private func configureHourlyForecast() {
        
        let oneHourViewSize = OneHourView.instanceFromNib().frame.size
                
        let parentView = self.hourlyForecastContainer
        parentView.showsHorizontalScrollIndicator = false
        parentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(parentView)
        
        NSLayoutConstraint.activate([
            parentView.topAnchor.constraint(equalTo: self.currentWeatherView.bottomAnchor,
                                            constant: self.verticalSpacing),
            parentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            parentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            parentView.heightAnchor.constraint(equalToConstant: oneHourViewSize.height),
        ])
        
//        parentView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: oneHourViewSize.height)
        
        
//        self.frame.size.height += parentView.frame.height + self.verticalSpacing //??????????
        
        print("HourlyWearher \(parentView.hasAmbiguousLayout)")
    }
    
    private func configureDailyForecast() {
        
        let oneDayViewHeight = OneDayView.instanceFronNib().frame.height
        
        let parentView = self.dailyForecastContainer
        parentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(parentView)
        
        NSLayoutConstraint.activate([
            parentView.topAnchor.constraint(equalTo: self.hourlyForecastContainer.bottomAnchor,
                                            constant: self.verticalSpacing),
            parentView.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                                constant: self.innerOffset),
            parentView.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                 constant: -self.innerOffset),
            parentView.heightAnchor.constraint(equalToConstant: oneDayViewHeight * 5), ////////////
            parentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
//        parentView.frame =  CGRect(x: self.innerOffset, y: 0, width: self.frame.width - (self.innerOffset * 2),
//                                   height: oneDayViewHeight * CGFloat(parentView.dailyForecastViews.count))
//        parentView.backgroundColor = .green
//        print(self.hourlyForecastContainer)
//        print(parentView)
        
//        self.frame.size.height += parentView.frame.height + self.verticalSpacing
        
        print("DailyWearher \(parentView.hasAmbiguousLayout)")
    }
    
    // MARK: - UI data update functions
        
    private func updateCurrentWeather(_ currentWeather: CurrentWeather?) {
        
        guard let data = currentWeather else { return }
        
        self.currentWeatherView.configure(isDayTime: data.isDayTime,
                                          temperature: Int(data.temperatureCelsius),
                                          weatherText: data.weatherText)
        self.viewModel.fetchImage(iconNumber: data.weatherIcon) { weatherIcon in
            self.currentWeatherView.setIcon(weatherIcon)
        }
    }
    
    
    
    
}
