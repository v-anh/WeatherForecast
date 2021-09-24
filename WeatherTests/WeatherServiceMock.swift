//
//  WeatherServiceMock.swift
//  WeatherTests
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
import RxSwift
@testable import Weather
class WeatherServiceMock: WeatherServiceType {
    var mockResult: GetWeatherResult? = .success(WeatherResponseModel.loadFromFile("WeatherResponse"))
    var searchTerm: String?
    var units: String?
    func getWeather(searchTerm: String, units: String) -> Observable<GetWeatherResult> {
        self.searchTerm = searchTerm
        self.units = units
        return .just(mockResult!)
    }
}

extension WeatherDisplayModel {
    static let mockExpected = {
        WeatherDisplayModel(date: 1632369600.0, averageTemp: 27.23, pressure: 1009.0, humidity: 67.0, description: "light rain", iconUrl: URL(string: "https://openweathermap.org/img/w/10d.png")!)
    }
}
