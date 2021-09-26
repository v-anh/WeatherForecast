//
//  WeatherDisplayModelTests.swift
//  WeatherTests
//
//  Created by Anh Tran on 26/09/2021.
//

import XCTest
@testable import Weather

class WeatherDisplayModelTests: XCTestCase {
    
    let weatherDisplayModel = WeatherDisplayModel(date: 0,
                                                  averageTemp: 1,
                                                  pressure: 2, humidity: 3,
                                                  description: "description",
                                                  iconUrl: URL(string: "url")!,
                                                  unitType: .Celsius)
    
    let mirror = WeatherDisplayModel(date: 0,
                                     averageTemp: 1,
                                     pressure: 2,
                                     humidity: 3,
                                     description: "description",
                                     iconUrl: URL(string: "url")!,
                                     unitType: .Celsius)
    
    let diffDate = WeatherDisplayModel(date: 1,
                                   averageTemp: 1,
                                   pressure: 2,
                                   humidity: 3,
                                   description: "description",
                                   iconUrl: URL(string: "url")!,
                                   unitType: .Celsius)
    
    let diffAverageTemp = WeatherDisplayModel(date: 0,
                                   averageTemp: 2,
                                   pressure: 2,
                                   humidity: 3,
                                   description: "description",
                                   iconUrl: URL(string: "url")!,
                                   unitType: .Celsius)
    
    let diffpressure = WeatherDisplayModel(date: 0,
                                   averageTemp: 1,
                                   pressure: 3,
                                   humidity: 3,
                                   description: "description",
                                   iconUrl: URL(string: "url")!,
                                   unitType: .Celsius)
    
    let diffHumidity = WeatherDisplayModel(date: 0,
                                   averageTemp: 1,
                                   pressure: 2,
                                   humidity: 4,
                                   description: "description",
                                   iconUrl: URL(string: "url")!,
                                   unitType: .Celsius)
    
    let diffDescription = WeatherDisplayModel(date: 0,
                                   averageTemp: 1,
                                   pressure: 2,
                                   humidity: 3,
                                   description: "descriptionNew",
                                   iconUrl: URL(string: "url")!,
                                   unitType: .Celsius)
    
    let diffUrl = WeatherDisplayModel(date: 0,
                                   averageTemp: 1,
                                   pressure: 2,
                                   humidity: 3,
                                   description: "description",
                                   iconUrl: URL(string: "urlnew")!,
                                   unitType: .Celsius)
    
    let diffUnitType = WeatherDisplayModel(date: 0,
                                   averageTemp: 1,
                                   pressure: 2,
                                   humidity: 3,
                                   description: "description",
                                   iconUrl: URL(string: "urlnew")!,
                                   unitType: .Fahrenheit)

    func testWeatherDisplayModelShouldSupportEqualtable() {
        //Given Mirror WeatherDisplayModel and different WeatherDisplayModel
        let differents = [diffDate,diffAverageTemp,
                          diffpressure,
                          diffHumidity,
                          diffDescription,
                          diffUrl,
                          diffUnitType]
        let mirror = mirror
        
        //Then weatherDisplayModel should equal to Mirror and Should NOT equal with different data of WeatherDisplayModel
        XCTAssertEqual(weatherDisplayModel, mirror)
        differents.forEach{ XCTAssertNotEqual(weatherDisplayModel, $0) }
    }
    
    func testWeatherDisplayModelHash()  {
        //Given expectedHasher of WeatherDisplayModel which is combine WeatherDidplayModel's properties
        var expectedHasher = Hasher()
        expectedHasher.combine(weatherDisplayModel.date)
        expectedHasher.combine(weatherDisplayModel.averageTemp)
        expectedHasher.combine(weatherDisplayModel.pressure)
        expectedHasher.combine(weatherDisplayModel.humidity)
        expectedHasher.combine(weatherDisplayModel.description)
        expectedHasher.combine(weatherDisplayModel.iconUrl)
        expectedHasher.combine(weatherDisplayModel.unitType.toString)
        
        
        var hasher = Hasher()
        weatherDisplayModel.hash(into: &hasher)
        XCTAssertEqual(expectedHasher.finalize(), hasher.finalize())
    }

}
