import UIKit

class WeatherInfoView: UIView {
    
    // MARK: - Properties
        
    let viewModel: WeatherInfoViewModel
    
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
        self.configure()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding functions
    
    func bindViewModel() {
        
        self.viewModel.didUpdateCurrentWeather = self.updateCurrentWeather(_:)
        self.viewModel.didUpdateHourlyForecast = self.hourlyForecastContainer.updateForecast(_:)
        self.viewModel.didUpdateDailyForecast = self.dailyForecastContainer.updateForecast(_:)
    }
    
    // MARK: - Configure functions
    
    func configure() {
        self.configureCurrentWearher()
        self.configureHourlyForecast()
        self.configureDailyForecast()
    }
    
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
                
        view.configure(isDayTime: self.viewModel.isDayTime)
    }
    
    private func configureHourlyForecast() {
                        
        let parentView = self.hourlyForecastContainer
        parentView.showsHorizontalScrollIndicator = false
        parentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(parentView)
        
        NSLayoutConstraint.activate([
            parentView.topAnchor.constraint(equalTo: self.currentWeatherView.bottomAnchor,
                                            constant: self.verticalSpacing),
            parentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            parentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    private func configureDailyForecast() {
        
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
            parentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    // MARK: - UI data update functions
        
    private func updateCurrentWeather(_ currentWeather: CurrentWeather?) {
        guard let data = currentWeather else { return }
        
        self.currentWeatherView.configure(isDayTime: data.isDayTime,
                                          temperature: Int(data.temperatureCelsius),
                                          weatherText: data.weatherText,
                                          weatherIcon: Int(data.weatherIcon))
    }
}
