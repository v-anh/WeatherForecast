//
//  WeatherListViewModel.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
import RxSwift
import RxCocoa

final class Scheduler {
    static var userInitiatedScheduler: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 5
        operationQueue.qualityOfService = QualityOfService.userInitiated
        return operationQueue
    }()
    
    static var backgroundScheduler: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        queue.qualityOfService = QualityOfService.background
        return queue
    }()

    static let mainScheduler = RunLoop.main
}

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

protocol WeatherConfigType {
    var unit: String {get}
    var mainScheduler: SchedulerType {get}
}

struct WeatherConfig: WeatherConfigType {
    var unit: String {
        "metric"
    }
    var mainScheduler: SchedulerType {
        MainScheduler.instance
    }
}

final class WeatherListViewModel: WeatherListViewModelType {
    
    enum WeatherSection: CaseIterable {
        case weatherList
    }
    
    let service: WeatherServiceType
    let config: WeatherConfigType
    
    private var disposeBag = DisposeBag()
    init(service: WeatherServiceType,
         config: WeatherConfigType,
         mainScheduler: SchedulerType = MainScheduler.instance) {
        self.service = service
        self.config = config
    }
    
    
    func transform(input: WeatherListViewModelInput) -> WeatherListViewModelOutput {
        let initialState = PublishRelay<SearchWeatherState>()
        let searchTerm = input.search
            .debounce(.milliseconds(300), scheduler: config.mainScheduler)
            .filter{$0.count > 3}

        let searchResult = searchTerm.flatMapLatest { [unowned self] searchTerm in
                self.service.getWeather(searchTerm: searchTerm,
                                        units: self.config.unit)
            }
            .map(weatherResultTranform(_:))
        
        let emptySearchInput = input.search
            .filter(\.isEmpty)
            .map{ _ in SearchWeatherState.empty}
        
        let weatherState = Observable.merge(initialState.asObservable(),searchResult,emptySearchInput)
        return WeatherListViewModelOutput(weatherSearchOutput: weatherState.asDriver(onErrorJustReturn: .empty))
    }
}

extension WeatherListViewModel {
    private func weatherResultTranform(_ result: GetWeatherResult) -> SearchWeatherState {
        switch result {
        case .success(let data):
            let displayModels = makeDisplayModels(data.list)
            return displayModels.isEmpty ? .empty : .loaded(displayModels)
        case .failure(let error):
            return .haveError(error)
        }
    }
    
    private func makeDisplayModels(_ weatherList: [WeatherFactor]?) -> [WeatherDisplayModel] {
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
                                iconUrl: url)
        }
    }
}
