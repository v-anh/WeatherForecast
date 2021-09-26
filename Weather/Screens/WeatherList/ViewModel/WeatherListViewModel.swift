//
//  WeatherListViewModel.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

struct WeatherListViewModelInput {
    let loadView: PublishRelay<Void>
    let search: PublishRelay<String>
}

struct WeatherListViewModelOutput {
    let weatherSearchOutput :Driver<SearchWeatherState>
}
protocol WeatherListViewModelType {
    func transform(input: WeatherListViewModelInput) -> WeatherListViewModelOutput
}

final class WeatherListViewModel: WeatherListViewModelType {
    
    enum WeatherSection: CaseIterable {
        case weatherList
    }
    
    let service: WeatherServiceType
    let cache: WeatherCacheServiceType
    let config: WeatherConfigType
    
    private var disposeBag = DisposeBag()
    init(service: WeatherServiceType,
         config: WeatherConfigType,
         cache: WeatherCacheServiceType = WeatherCacheService()) {
        self.service = service
        self.config = config
        self.cache = cache
    }
    
    func transform(input: WeatherListViewModelInput) -> WeatherListViewModelOutput {
        let initialState = input.loadView.map{ _ in SearchWeatherState.empty }
        let searchTerm = input.search
            .debounce(.milliseconds(300), scheduler: config.mainScheduler)
            .filter{$0.count > 3}
        
        let requestParameter = searchTerm.map { [unowned self] searchTerm in
            return WeatherSearchParameter(searchTerm: searchTerm,
                                          unit: self.config.unit.parameter,
                                          cnt: self.config.cnt)
        }.share()

        let cachedResult = requestParameter
            .flatMapLatest { [unowned self] parameter in
                return self.cache.getWeather(key: Self.makeWeatherReponseCacheKey(parameter)).materialize()
            }
            .elements()
            .map{ [unowned self] model -> SearchWeatherState in
                let displayModels = Self.makeDisplayModels(model.list,
                                                           unitType: self.config.unit)
                return SearchWeatherState.loaded(displayModels)
            }
            .share()
        
        let searchRequest = requestParameter
            .flatMapLatest { [unowned self] parameter -> Observable<GetWeatherResult> in
                return self.service.getWeather(parameter)
            }
            .share(replay: 1, scope: .whileConnected)
              
        searchRequest
            .map { try? $0.get() }
            .unwrap()
            .withLatestFrom(requestParameter) {($0,$1)}
            .flatMap { [unowned self] response, parameter in
                self.cache
                    .setWeather(response, key: Self.makeWeatherReponseCacheKey(parameter))
                    .catch { _ in return .just(()) }
            }.subscribe()
            .disposed(by: disposeBag)
        
        let searchResult = searchRequest
            .map{ [unowned self ] result -> SearchWeatherState in
                return Self.weatherResultTranform(result,
                                                  unitType: self.config.unit)}
        
        let result = Observable.merge(searchResult,cachedResult)
        
        let emptySearchInput = input.search
            .filter(\.isEmpty)
            .map{ _ in SearchWeatherState.empty}
        
        let weatherState = Observable.merge(initialState,result,emptySearchInput)
        return WeatherListViewModelOutput(weatherSearchOutput: weatherState.asDriver(onErrorJustReturn: .empty))
    }
}

extension WeatherListViewModel {
    
    private static func makeWeatherReponseCacheKey(_ parameter: WeatherSearchParameter) -> String {
        return parameter.searchTerm +
            parameter.unit +
           "\(parameter.cnt)"
    }
    private static func weatherResultTranform(_ result: GetWeatherResult, unitType: UnitType) -> SearchWeatherState {
        switch result {
        case .success(let data):
            let displayModels = makeDisplayModels(data.list, unitType: unitType)
            return displayModels.isEmpty ? .empty : .loaded(displayModels)
        case .failure(let error):
            return .haveError(error)
        }
    }
    
    private static func makeDisplayModels(_ weatherList: [WeatherFactor]?, unitType: UnitType) -> [WeatherDisplayModel] {
        guard let weatherList = weatherList,
              !weatherList.isEmpty else {return []}
        
        return weatherList.compactMap { weatherfactor -> WeatherDisplayModel? in
            guard let temp = weatherfactor.temp,
                  let dt = weatherfactor.dt,
                  let averageTemp = temp.eve,
                  let pressure = weatherfactor.pressure,
                  let humidity = weatherfactor.humidity,
                  let weather = weatherfactor.weather?.first,
                  let description = weather.weatherDescription,
                  let icon = weather.icon,
                  let url = URL.pngIconUrl(icon)
            else {
                return nil
            }
            return WeatherDisplayModel(date: dt,
                                averageTemp: averageTemp,
                                pressure: pressure,
                                humidity: humidity,
                                description: description,
                                iconUrl: url,
                                unitType: unitType)
        }
    }
}
