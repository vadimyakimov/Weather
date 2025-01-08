import CoreData

protocol SearchScreenViewModelCreator {
    func createSearchScreenViewModel() -> SearchScreenViewModelProtocol
}

protocol CitiesListViewModelCreator {
    func createCitiesListViewModel() -> CitiesListViewModelProtocol
}

protocol CitiesPageViewModelCreator {
    func createCitiesPageViewModel() -> CitiesPageViewModelProtocol
}

protocol CityViewModelCreator {
    func createCityViewModel(withIndex index: Int) -> CityViewModelProtocol
}

protocol WeatherInfoViewModelCreator {
    func createWeatherInfoViewModel() -> WeatherInfoViewModelProtocol
}

/// -----------------------

protocol CitiesCountProviding {
    var citiesCount: Int { get }
}

protocol DayTimeProviding {
    var isDayTime: Bool { get }
}

protocol EmptyStateProviding {
    var isEmpty: Bool { get }
}

protocol CityElementProviding {
    func city(at index: Int) -> CityDataProviding?
}

/// -----------------------

protocol WeatherInfoViewModelProtocol: AnyObject, DayTimeProviding {
    
    var currentWeather: Bindable<CurrentWeatherProviding?> { get }
    var hourlyForecast: Bindable<[HourlyForecastProviding]?> { get }
    var dailyForecast: Bindable<[DailyForecastProviding]?> { get }
    
    var isImperial: Bindable<Bool> { get }
    
    var delegate: WeatherInfoViewDelegate? { get set }
    
    func refreshWeather(isForcedUpdate: Bool)
}

protocol CityViewModelProtocol: WeatherInfoViewModelCreator, DayTimeProviding {
    var cityName: String { get }
    var cityId: Int { get }
}

protocol CitiesPageViewModelProtocol: CitiesListViewModelCreator, CityViewModelCreator, CitiesCountProviding { }

protocol CitiesListViewModelProtocol: SearchScreenViewModelCreator, CitiesCountProviding, EmptyStateProviding, CityElementProviding {
    
    var frc: NSFetchedResultsController<City> { get }
    var hasLocatedCity: Bool { get }
    
    func removeCityAt(_ index: Int)
    func moveCity(at sourceIndex: Int, to destinationIndex: Int) 
}

protocol SearchScreenViewModelProtocol: CitiesCountProviding, CityElementProviding {
    var delegate: SearchScreenViewControllerDelegate? { get set }
    var citiesAutocompleteArray: Bindable<[CityDataProviding]> { get }
    var isLocationLoading: Bindable<GeoDetectingState> { get }
    
    func fetchAutocompleteArray(for searchText: String)
    func handleSelectedRow(at indexPath: IndexPath)
}

protocol MainNavigationViewModelProtocol: SearchScreenViewModelCreator, CitiesPageViewModelCreator, EmptyStateProviding { }
