//
//  WeatherInfoView.swift
//  Weather 2
//
//  Created by Вадим on 08.02.2022.
//

import UIKit

class WeatherInfoView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: WeatherInfoViewDelegate?
    
    private let city: City
    private let verticalSpacing: CGFloat = 30
    
    // API keys
    
    private let baseURL = "https://dataservice.accuweather.com"
    private let language = "language=" + "en-us".localized()
    private let keyAccuAPI = "pUPRp5bjAvEajZjEA6kc6yPSlbYMhXRZ"
    //pUPRp5bjAvEajZjEA6kc6yPSlbYMhXRZ
    //YyRHncuTlsidjyS4YVziEZPChV4sPDVA
    //dcXaSaOT2bTNKzDiMD37dnGlZXGEeTxG
    //WaP8kp90kGrPCypoU4Tp7mmQKcnG9YUe
    //aclG15Tu7dG0kikCCAYWL2TiCgNp6I6y
    
    private let keyCityName = "LocalizedName"
    private let keyCityID = "Key"
    
    private let keyIsDayTime = "IsDayTime"
    private let keyWeatherIcon = "WeatherIcon"
    private let keyWeatherText = "WeatherText"
    private let keyForecastWeatherText = "IconPhrase"
    private let keyDailyForecastWeatherIcon = "Icon"
    
    private let keyTemperature = "Temperature"
    private let keyTemperatureValue = "Value"
    private let keyCelsius = "Metric"
    
    private let keyMinimum = "Minimum"
    private let keyMaximum = "Maximum"
    
    private let keyDay = "Day"
    private let keyNight = "Night"
    
    private let keyDailyForecast = "DailyForecasts"
    
    private let keyHourlyDate = "EpochDateTime"
    private let keyDailyDate = "EpochDate"
    
    
    // MARK: - Initializers
    
    init(for city: City, width: CGFloat) {
        self.city = city
        
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        
        self.frame.size.width = width
        
        self.configure()
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure functions
    
    private func configure() {
        self.frame.size.height += self.verticalSpacing
//        self.configureCurrentWearher()
//        self.configureHourlyForecast()
//        self.configureDailyForecast()
        
    }
    
    private func configureCurrentWearher() {
               
        let top = self.frame.height
        let width = self.frame.width
        
        let currentWeatherView = CurrentWeatherView.instanceFromNib()
        let currentWeatherViewSide = currentWeatherView.frame.width
        
        currentWeatherView.configure()
        currentWeatherView.frame.origin = CGPoint(x: (width - currentWeatherViewSide) / 2, y: top)
        
        self.addSubview(currentWeatherView)
        
        self.frame.size.height += currentWeatherViewSide + self.verticalSpacing
        
        if let currentWeather = self.city.currentWeather,
           self.city.lastUpdated.currentWeather.timeIntervalSinceNow > -600 {
            self.updateDataInView(currentWeatherView, data: currentWeather)
        } else {
            self.getCurrentWeather(for: self.city.id) { currentWeather in
                self.city.currentWeather = currentWeather
                self.updateDataInView(currentWeatherView, data: currentWeather)
                self.delegate?.weatherInfoView(didUpdateCurrentWeatherFor: self.city)
            }
        }
        
    }
    
    
    private func configureHourlyForecast() {
        
        let top = self.frame.height
        let width = self.frame.width
        
        let offsetBetween: CGFloat = 20
        let oneHourViewSize = OneHourView.instanceFromNib().frame.size
        var contentWidth = offsetBetween
        
        var oneHourViewsArray = [OneHourView](repeating: OneHourView(), count: 12)
        
        let hourlyScrollView = UIScrollView(frame: CGRect(x: 0,
                                                          y: top,
                                                          width: width,
                                                          height: oneHourViewSize.height))
        hourlyScrollView.showsHorizontalScrollIndicator = false
        self.addSubview(hourlyScrollView)
        
        
        for index in 0..<oneHourViewsArray.count {
            let oneHourView = OneHourView.instanceFromNib()
            oneHourView.configure()
            oneHourView.frame.origin = CGPoint(x: contentWidth, y: 0)
            hourlyScrollView.addSubview(oneHourView)
            
            oneHourViewsArray[index] = oneHourView
            
            contentWidth += oneHourViewSize.width + offsetBetween            
        }
        
        hourlyScrollView.contentSize.width = contentWidth
        
        self.frame.size.height += hourlyScrollView.frame.height + self.verticalSpacing
        
        
        if let hourlyForecast = self.city.hourlyForecast,
           self.city.lastUpdated.hourlyForecast.timeIntervalSinceNow > -600 {
            self.updateDataInView(oneHourViewsArray, data: hourlyForecast)
        } else {
            self.getHourlyForecast(for: self.city.id) { hourlyForecast in
                self.city.hourlyForecast = hourlyForecast
                self.updateDataInView(oneHourViewsArray, data: hourlyForecast)
            }
        }
        
    }
    
    private func configureDailyForecast() {
        
        let top = self.frame.height
        let width = self.frame.width
        
        let horizontalOffset: CGFloat = 20
        let dailyViewCornerRadius: CGFloat = 20
        
        var oneDayViewsArray = [OneDayView](repeating: OneDayView(), count: 5)
        
        let oneDayViewHeight = OneDayView.instanceFronNib().frame.height
        
        let dailyView = UIView(frame: CGRect(x: horizontalOffset,
                                             y: top,
                                             width: width - (horizontalOffset * 2),
                                             height: oneDayViewHeight * CGFloat(oneDayViewsArray.count)))
        dailyView.clipsToBounds = true
        dailyView.layer.cornerRadius = dailyViewCornerRadius
        self.addSubview(dailyView)
        
        for index in 0..<oneDayViewsArray.count {
            let oneDayView = OneDayView.instanceFronNib()
            oneDayView.configure()
            oneDayView.frame.origin = CGPoint(x: 0, y: oneDayViewHeight * CGFloat(index))
            oneDayView.frame.size.width = dailyView.frame.width
            oneDayViewsArray[index] = oneDayView
            dailyView.addSubview(oneDayView)
        }
        
        self.frame.size.height += dailyView.frame.height + self.verticalSpacing
        
        if let dailyForecast = self.city.dailyForecast,
           self.city.lastUpdated.dailyForecast.timeIntervalSinceNow > -600 {
            self.updateDataInView(oneDayViewsArray, data: dailyForecast)
        } else {
            self.getDailyForecast(for: self.city.id) { dailyForecast in
                self.city.dailyForecast = dailyForecast
                self.updateDataInView(oneDayViewsArray, data: dailyForecast)
            }
        }
    }
    
    // MARK: - View's data update functions
    
    private func updateDataInView(_ view: CurrentWeatherView, data: CurrentWeather) {
        view.configure(isDayTime: data.isDayTime,
                       temperature: data.temperatureCelsius,
                       weatherText: data.weatherText)
        self.getImage(iconNumber: data.weatherIcon) { weatherIcon in
            view.setIcon(weatherIcon)
        }
    }
    
    private func updateDataInView(_ views: [OneHourView], data: [HourlyForecast]?) {
        guard let data = data else { return }
        guard data.count == views.count else { return }
        for (index, view) in views.enumerated() {
            view.configure(time: data[index].forecastTime,
                           temperature: data[index].temperatureCelsius,
                           weatherText: data[index].weatherText)
            self.getImage(iconNumber: data[index].weatherIcon) { weatherIcon in
                view.setIcon(weatherIcon)
            }
        }
    }
    
    private func updateDataInView(_ views: [OneDayView], data: [DailyForecast]?) {
        guard let data = data else { return }
        guard data.count == views.count else { return }
        
        for (index, view) in views.enumerated() {
            view.configure(date: data[index].forecastDate,
                           dayTemperature: data[index].dayWeather.temperatureCelsius,
                           nightTemperature: data[index].nightWeather.temperatureCelsius)
            self.getImage(iconNumber: data[index].dayWeather.weatherIcon) { dayIcon in
                view.setDayIcon(dayIcon)
            }
            self.getImage(iconNumber: data[index].nightWeather.weatherIcon) { nightIcon in
                view.setNightIcon(nightIcon)
            }
        }
    }
    
    // MARK: - Server connection functions
        
    private func getCurrentWeather(for id: String, complete: @escaping(CurrentWeather) -> () ) {
        let urlString = "\(self.baseURL)/currentconditions/v1/\(id)?apikey=\(self.keyAccuAPI)&\(self.language)"
        guard let url = URL(string: urlString) else { return }
                
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let d = data, error == nil else { return }
            let currentWeather = try? JSONSerialization.jsonObject(with: d, options: .mutableContainers) as? [[String : Any]]
            
            guard let parsedCurrentWeather = self.parseCurrentWearher(from: currentWeather) else { return }
            
            self.city.currentWeather = parsedCurrentWeather
            self.city.lastUpdated.currentWeather = Date()
            
            DispatchQueue.main.async {
                complete(parsedCurrentWeather)
            }
        }.resume()
    }
    
    private func getHourlyForecast(for id: String, complete: @escaping([HourlyForecast]) -> () ) {
        let urlString = "\(self.baseURL)/forecasts/v1/hourly/12hour/\(id)?apikey=\(self.keyAccuAPI)&\(language)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let d = data, error == nil else { return }
            let hourlyForecastArray = try? JSONSerialization.jsonObject(with: d, options: .mutableContainers) as? [[String : Any]]
            
            guard let parsedHourlyForecastArray = self.parseHourlyForecastArray(from: hourlyForecastArray) else { return }
            
            self.city.hourlyForecast = parsedHourlyForecastArray
            self.city.lastUpdated.hourlyForecast = Date()
            
            DispatchQueue.main.async {
                complete(parsedHourlyForecastArray)
            }
        }.resume()
    }
    
    private func getDailyForecast(for id: String, complete: @escaping([DailyForecast]) -> () ) {
        let urlString = "\(self.baseURL)/forecasts/v1/daily/5day/\(id)?apikey=\(self.keyAccuAPI)&\(language)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let d = data, error == nil else { return }
            let dailyForecastDictionary = try? JSONSerialization.jsonObject(with: d, options: .mutableContainers) as? [String : Any]
            
            guard let parsedDailyForecastDictionary = self.parseDailyForecastDictionary(from: dailyForecastDictionary) else { return }
            
            self.city.dailyForecast = parsedDailyForecastDictionary
            self.city.lastUpdated.dailyForecast = Date()
            
            DispatchQueue.main.async {
                complete(parsedDailyForecastDictionary)
            }
        }.resume()
    }
    
    private func parseCurrentWearher(from dataArray: [[String : Any]]?) -> CurrentWeather? {
        guard let dataDictionary = dataArray?.first else { return nil }
        
        let temperatureDictionary = dataDictionary[self.keyTemperature] as? [String:Any]
        let temperatureCelsiusDictionary = temperatureDictionary?[self.keyCelsius] as? [String:Any]
        guard let temperatureCelsius = temperatureCelsiusDictionary?[self.keyTemperatureValue] as? Double else { return nil }
        
        guard let isDayTime = dataDictionary[self.keyIsDayTime] as? Bool else { return nil }
        guard let weatherIcon = dataDictionary[self.keyWeatherIcon] as? Int else { return nil }
        guard let weatherText = dataDictionary[self.keyWeatherText] as? String else { return nil }
        
        let currentWeather = CurrentWeather(isDayTime: isDayTime,
                                            temperatureCelsius: Int(round(temperatureCelsius)),
                                            weatherIcon: weatherIcon,
                                            weatherText: weatherText)
        return currentWeather
    }
    
    private func parseHourlyForecastArray(from dataArray: [[String : Any]]?) -> [HourlyForecast]? {
        guard let dataArray = dataArray else { return nil }
        
        var hourlyForecastArray: [HourlyForecast] = []
        
        for dataDictionary in dataArray {
            let temperatureDictionary = dataDictionary[self.keyTemperature] as? [String:Any]
            guard let temperatureCelsius = temperatureDictionary?[self.keyTemperatureValue] as? Double else { return nil }
            guard let weatherIcon = dataDictionary[self.keyWeatherIcon] as? Int else { return nil }
            guard let weatherText = dataDictionary[self.keyForecastWeatherText] as? String else { return nil }
            guard let epochDate = dataDictionary[self.keyHourlyDate] as? TimeInterval else { return nil }
            let date = Date(timeIntervalSince1970: epochDate)
            
            
            
            hourlyForecastArray.append(HourlyForecast(forecastTime: date,
                                                      temperatureCelsius: Int(round(temperatureCelsius)),
                                                      weatherIcon: weatherIcon,
                                                      weatherText: weatherText))
        }
        return hourlyForecastArray
    }
    
    private func parseDailyForecastDictionary(from data: [String : Any]?) -> [DailyForecast]? {
        guard let dataArray = data?[self.keyDailyForecast] as? [[String : Any]] else { return nil }
        
        var dailyForecastArray: [DailyForecast] = []
        
        for dataDictionary in dataArray {
            let temperatureDictionary = dataDictionary[self.keyTemperature] as? [String : Any]
            let temperatureMinimumDictionary = temperatureDictionary?[self.keyMinimum] as? [String : Any]
            let temperatureMaximumDictionary = temperatureDictionary?[self.keyMaximum] as? [String : Any]
            guard let temperatureMinimumValueDictionary = temperatureMinimumDictionary?[self.keyTemperatureValue] as? Double else { return nil }
            guard let temperatureMaximumValueDictionary = temperatureMaximumDictionary?[self.keyTemperatureValue] as? Double else { return nil }
            
            let dayDictionary = dataDictionary[self.keyDay] as? [String : Any]
            guard let dayIcon = dayDictionary?[self.keyDailyForecastWeatherIcon] as? Int else { return nil }
            guard let dayText = dayDictionary?[self.keyForecastWeatherText] as? String else { return nil }
            
            let nightDictionary = dataDictionary[self.keyNight] as? [String : Any]
            guard let nightIcon = nightDictionary?[self.keyDailyForecastWeatherIcon] as? Int else { return nil }
            guard let nightText = nightDictionary?[self.keyForecastWeatherText] as? String else { return nil }
            
            guard let epochDate = dataDictionary[self.keyDailyDate] as? TimeInterval else { return nil }
            let date = Date(timeIntervalSince1970: epochDate)
            
            dailyForecastArray.append(DailyForecast(forecastDate: date,
                                                    temperatureCelsiusMinimum: Int(round(temperatureMinimumValueDictionary)),
                                                    temperatureCelsiusMaximum: Int(round(temperatureMaximumValueDictionary)),
                                                    dayWeatherIcon: dayIcon,
                                                    dayWeatherText: dayText,
                                                    nightWeatherIcon: nightIcon,
                                                    nightWeatherText: nightText))
        }
        return dailyForecastArray
    }
    
    private func getImage(iconNumber: Int, complete: @escaping(UIImage) -> ()) {
        
        let numberFormatted = String(format: "%02d", iconNumber)
        let urlString = "https://developer.accuweather.com/sites/default/files/" + numberFormatted + "-s.png"
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        complete(loadedImage)
                    }
                }
            }
        }
    }
    
}
