//
//  WeatherService.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
import RxSwift

typealias GetWeatherResult = Result<WeatherResponseModel,APIError>

struct WeatherSearchParameter {
    let searchTerm: String
    let unit: String
    let cnt: Float
}

protocol WeatherServiceType {
    func getWeather(_ parameter: WeatherSearchParameter) -> Observable<GetWeatherResult>
}

public struct WeatherService: WeatherServiceType {
    private let networkService:NetworkServiceType
    
    public init(_ networkService: NetworkServiceType) {
        self.networkService = networkService
    }
    func getWeather(_ parameter: WeatherSearchParameter) -> Observable<GetWeatherResult> {
        let weatherRequest = WeatherRequest(searchTerm: parameter.searchTerm,
                                            units: parameter.unit,
                                            cnt: parameter.cnt)
        
        return networkService.request(weatherRequest, type: WeatherResponseModel.self)
    }
}
