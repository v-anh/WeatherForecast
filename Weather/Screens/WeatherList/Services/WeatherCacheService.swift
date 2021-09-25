//
//  WeatherCacheService.swift
//  Weather
//
//  Created by Anh Tran on 25/09/2021.
//

import Foundation
import RxSwift

protocol WeatherCacheServiceType {
    func getWeather(key: String) -> Observable<WeatherResponseModel>
    func setWeather(_ weather: WeatherResponseModel ,key: String) -> Observable<Void>
}

struct WeatherCacheService: WeatherCacheServiceType {
    let cache = Cache.shared
    func setWeather(_ weather: WeatherResponseModel, key: String) -> Observable<Void>{
        return cache.insert(object: weather, key: key)
    }
    
    func getWeather(key: String) -> Observable<WeatherResponseModel> {
        return cache.object(for: key,type: WeatherResponseModel.self)
    }
}
