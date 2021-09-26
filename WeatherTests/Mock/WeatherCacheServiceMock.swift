//
//  WeatherCacheServiceMock.swift
//  WeatherTests
//
//  Created by Anh Tran on 25/09/2021.
//

import Foundation
import RxSwift
@testable import Weather
class WeatherCacheServiceMock: WeatherCacheServiceType {
    var mockResult:Observable<WeatherResponseModel> = .error(CacheError.getObject)
    var getWeatherKeyHooked: String? = nil
    func getWeather(key: String) -> Observable<WeatherResponseModel> {
        getWeatherKeyHooked = key
        return mockResult
    }
    
    var weatherParameterhook:WeatherResponseModel? = nil
    var setWeatherKeyHooked: String? = nil
    func setWeather(_ weather: WeatherResponseModel, key: String) -> Observable<Void> {
        weatherParameterhook = weather
        setWeatherKeyHooked = key
        return .just(())
    }
}
