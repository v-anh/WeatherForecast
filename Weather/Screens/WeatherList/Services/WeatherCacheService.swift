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
    let cache:CacheProtocol
    
    init(_ cache: CacheProtocol = Cache.shared) {
        self.cache = cache
    }
    func setWeather(_ weather: WeatherResponseModel, key: String) -> Observable<Void>{
        return cache.set(object: weather, key: key)
    }
    
    func getWeather(key: String) -> Observable<WeatherResponseModel> {
        return cache.get(for: key,type: WeatherResponseModel.self)
    }
}
