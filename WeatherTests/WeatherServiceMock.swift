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
    var parameter: WeatherSearchParameter?
    func getWeather(_ parameter: WeatherSearchParameter) -> Observable<GetWeatherResult> {
        self.parameter = parameter
        return .just(mockResult!)
    }
}

extension WeatherDisplayModel {
    static let mockExpected = {
        WeatherDisplayModel(date: 1632369600.0, averageTemp: 27.23, pressure: 1009.0, humidity: 67.0, description: "light rain", iconUrl: URL(string: "https://openweathermap.org/img/w/10d.png")!, unitType: UnitType.Celsius)
    }
}

extension WeatherResponseModel: Equatable {
    
    static let stub = {
        WeatherResponseModel.loadFromFile("WeatherResponse")
    }
    
    static func inConsistenceStub(_ weatherList: [WeatherFactor]? = nil) -> WeatherResponseModel {
        return WeatherResponseModel(cod: nil,
                                    message: nil,
                                    cnt: nil,
                                    city: nil,
                                    list: weatherList)
    }
    
    public static func == (lhs: WeatherResponseModel, rhs: WeatherResponseModel) -> Bool {
        return lhs.cod == rhs.cod &&
        lhs.message == rhs.message &&
        lhs.cnt == rhs.cnt &&
        lhs.city == rhs.city &&
        lhs.list == rhs.list
    }
}

extension City: Equatable {
    public static func == (lhs: City, rhs: City) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name
        
    }
}
extension WeatherFactor: Equatable {
    static func inConsistenceStub(dt: TimeInterval? = nil,
                                  temp: Temp? = nil,
                                  pressure: Double? = nil,
                                  humidity: Double? = nil,
                                  weather: [Weather]? = nil) -> WeatherFactor {
        return WeatherFactor(dt: dt,
                             sunrise: nil,
                             sunset: nil,
                             temp: temp,
                             pressure: pressure,
                             humidity: humidity,
                             weather: weather,
                             speed: nil,
                             deg: nil,
                             gust: nil,
                             clouds: nil,
                             pop: nil,
                             rain: nil)
    }
    public static func == (lhs: WeatherFactor, rhs: WeatherFactor) -> Bool {
        return lhs.dt == rhs.dt &&
            lhs.sunset == rhs.sunset &&
            lhs.sunrise == rhs.sunrise &&
            lhs.temp == rhs.temp &&
            lhs.pressure == rhs.pressure &&
            lhs.humidity == rhs.humidity &&
            lhs.weather == rhs.weather &&
            lhs.speed == rhs.speed &&
            lhs.deg == rhs.deg &&
            lhs.gust == rhs.gust &&
            lhs.clouds == rhs.clouds &&
            lhs.pop == rhs.pop &&
            lhs.rain == rhs.rain
    }
}
extension Temp: Equatable {
    public static func == (lhs: Temp, rhs: Temp) -> Bool {
        return lhs.eve == rhs.eve
    }
}
extension Weather: Equatable {
    public static func == (lhs: Weather, rhs: Weather) -> Bool {
        return lhs.id == rhs.id &&
            lhs.main == rhs.main &&
            lhs.weatherDescription == rhs.weatherDescription &&
            lhs.icon == rhs.icon
    }
}
