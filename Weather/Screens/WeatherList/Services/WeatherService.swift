//
//  WeatherService.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
import RxSwift

typealias GetWeatherResult = Result<WeatherResponseModel,APIError>
protocol WeatherServiceType {
    func getWeather(searchTerm: String, units: String) -> Observable<GetWeatherResult>
}

public struct WeatherService: WeatherServiceType {
    private let networkService:NetworkServiceType
    
    public init(_ networkService: NetworkServiceType) {
        self.networkService = networkService
    }
    func getWeather(searchTerm: String, units: String) -> Observable<GetWeatherResult> {
        let weatherRequest = WeatherRequest(searchTerm: searchTerm, units: units)
        
        return networkService.request(weatherRequest, type: WeatherResponseModel.self)
    }
}
