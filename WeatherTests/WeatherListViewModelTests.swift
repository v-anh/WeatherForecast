//
//  WeatherListViewModelTests.swift
//  WeatherTests
//
//  Created by Anh Tran on 23/09/2021.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import Weather


struct WeatherConfigMock: WeatherConfigType {
    var unit: UnitType = .Celsius
    
    var cnt: Float = 2.5
    
    var mainScheduler: SchedulerType = MainScheduler.instance
}
class WeatherListViewModelTests: XCTestCase {

    var viewModel: WeatherListViewModel!
    var serviceMock: WeatherServiceMock!
    var cacheMock: WeatherCacheServiceMock!
    var config: WeatherConfigMock!
    var scheduler: TestScheduler!

    var disposeBag: DisposeBag!
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        serviceMock = WeatherServiceMock()
        cacheMock = WeatherCacheServiceMock()
        config = WeatherConfigMock()
        config.mainScheduler = scheduler
        viewModel = WeatherListViewModel(service: serviceMock,
                                         config: config,
                                         cache: cacheMock)
    }
    
    override func tearDown() {
        scheduler = nil
        viewModel = nil
        disposeBag = nil
    }
    
    
    //MARK: Test Weather Success Flow
    func testShouldReturnEmptyStateWhenLoadView() {
        //Given input loadview
        let loadView = PublishRelay<Void>()
        let search = PublishRelay<String>()
        let result = scheduler.createObserver(SearchWeatherState.self)
        
        let output = viewModel.transform(input: WeatherListViewModelInput(loadView: loadView,
                                                                          search: search))
        output.weatherSearchOutput
            .drive(result)
            .disposed(by: disposeBag)
        
        //When trigger load view
        loadView.accept(())
        scheduler.start()
        
        //Then expect output should be empty state and just one event emitted
        XCTAssertEqual(result.events.count,1)
        XCTAssertEqual(result.events.compactMap(pullBackToElement).last,.empty)
    }
    
    func testShouldReturnLoadedStateWhenTriggerSearch() {
        //Given ViewModel input
        let loadView = PublishRelay<Void>()
        let search = PublishRelay<String>()
        let result = scheduler.createObserver(SearchWeatherState.self)
        
        let output = viewModel.transform(input: WeatherListViewModelInput(loadView: loadView,
                                                                          search: search))
        output.weatherSearchOutput
            .drive(result)
            .disposed(by: disposeBag)
        
        //When trigger loadview and search
        loadView.accept(())
        search.accept("saigon")
        scheduler.start()
        
        //Then expect output should be empty state and just one event emitted
        XCTAssertEqual(result.events.count,2)
        XCTAssertEqual(result.events.compactMap(pullBackToElement),[.empty,.loaded([.mockExpected()])])
        XCTAssertEqual(serviceMock.parameter?.searchTerm,"saigon")
        XCTAssertEqual(serviceMock.parameter?.unit,"metric")
    }
    
    func testShouldNotTriggerSearchRequestWhenTriggerSearchTermTooShort() {
        //Given ViewModel input
        let loadView = PublishRelay<Void>()
        let search = PublishRelay<String>()
        let result = scheduler.createObserver(SearchWeatherState.self)
        
        let output = viewModel.transform(input: WeatherListViewModelInput(loadView: loadView,
                                                                          search: search))
        output.weatherSearchOutput
            .drive(result)
            .disposed(by: disposeBag)
        
        //When trigger loadview and search
        loadView.accept(())
        search.accept("Sa")
        scheduler.start()
        
        //Then expect output should be empty state and just one event emitted
        XCTAssertEqual(result.events.count,1)
        XCTAssertEqual(result.events.compactMap(pullBackToElement),[.empty])
    }
    
    func testShouldDebounceBeforeTriggerSearchTerm() {
        //Given ViewModel input
        let loadView = PublishRelay<Void>()
        let search = PublishRelay<String>()
        let result = scheduler.createObserver(SearchWeatherState.self)
        
        //Bind data to output
        let output = viewModel.transform(input: WeatherListViewModelInput(loadView: loadView,
                                                                          search: search))
        output.weatherSearchOutput
            .drive(result)
            .disposed(by: disposeBag)
        loadView.accept(())
        
        //When trigger multiple search
        scheduler.createColdObservable([.next(0, "Sai"),.next(1, "Saig"),.next(2, "Saigo"),.next(3, "Saigon")])
            .bind(to: search)
            .disposed(by: disposeBag)
        scheduler.start()
        
        //Then expect just last searchterm be triggered and output should be two even is empty and loaded
        XCTAssertEqual(result.events.count,2)
        XCTAssertEqual(result.events.compactMap(pullBackToElement),[.empty, .loaded([.mockExpected()])])
        XCTAssertEqual(serviceMock.parameter?.searchTerm,"Saigon")
        XCTAssertEqual(serviceMock.parameter?.unit,"metric")
        XCTAssertEqual(serviceMock.parameter?.cnt,2.5)
    }
    
    
    //MARK: - Test Search Weather Flow With Cache
    func testShouldReturnCacheWhenCacheAvailabelForSeachWeather() {
        //Given ViewModel input & Mock cache data
        let loadView = PublishRelay<Void>()
        let search = PublishRelay<String>()
        let result = scheduler.createObserver(SearchWeatherState.self)
        cacheMock.mockResult = .just(.stub())
        
        let output = viewModel.transform(input: WeatherListViewModelInput(loadView: loadView,
                                                                          search: search))
        output.weatherSearchOutput
            .drive(result)
            .disposed(by: disposeBag)
        
        //When trigger loadview and search
        loadView.accept(())
        search.accept("saigon")
        scheduler.start()
        
        //Then expect output should be three events: init as empty, loaded with cache and server response
        XCTAssertEqual(result.events.count,3)
        XCTAssertEqual(result.events.compactMap(pullBackToElement),[.empty,.loaded([.mockExpected()]),.loaded([.mockExpected()])])
        XCTAssertEqual(serviceMock.parameter?.searchTerm,"saigon")
        XCTAssertEqual(serviceMock.parameter?.unit,"metric")
        XCTAssertEqual(cacheMock.getWeatherKeyHooked,"saigonmetric2.5")
    }
    
    func testShouldPersistWeatherDataToCacheAfterFetchFromServer() {
        //Given ViewModel input with invalid cache
        let loadView = PublishRelay<Void>()
        let search = PublishRelay<String>()
        
        let output = viewModel.transform(input: WeatherListViewModelInput(loadView: loadView,
                                                                          search: search))
        output.weatherSearchOutput
            .drive()
            .disposed(by: disposeBag)
        
        //When trigger loadview and search
        loadView.accept(())
        search.accept("saigon")
        scheduler.start()
        
        //Then expect output should be three events: init as empty, loaded with cache and server response
        XCTAssertEqual(cacheMock.setWeatherKeyHooked,"saigonmetric2.5")
        XCTAssertEqual(cacheMock.weatherParameterhook?.cod,WeatherResponseModel.stub().cod)
    }
    
    
    //Error
    func testShouldHandleErrorWhenSearchApiResponseError() {
        //Given ViewModel input & Mock search weather with error
        let loadView = PublishRelay<Void>()
        let search = PublishRelay<String>()
        let result = scheduler.createObserver(SearchWeatherState.self)
        serviceMock.mockResult = .failure(APIError.badRequest)
        
        let output = viewModel.transform(input: WeatherListViewModelInput(loadView: loadView,
                                                                          search: search))
        output.weatherSearchOutput
            .drive(result)
            .disposed(by: disposeBag)
        
        //When trigger loadview and search
        loadView.accept(())
        search.accept("saigon")
        scheduler.start()
        
        //Then expect output should be three events: init as empty and error
        XCTAssertEqual(result.events.count,2)
        XCTAssertEqual(result.events.compactMap(pullBackToElement),[.empty,.haveError(APIError.badRequest)])
        XCTAssertEqual(serviceMock.parameter?.searchTerm,"saigon")
        XCTAssertEqual(serviceMock.parameter?.unit,"metric")
        XCTAssertEqual(cacheMock.getWeatherKeyHooked,"saigonmetric2.5")
    }
    
    func testShouldNotPersistCacheWhenSearchApiHaveErorr() {
        //Given ViewModel input & Mock search weather with error
        let loadView = PublishRelay<Void>()
        let search = PublishRelay<String>()
        let result = scheduler.createObserver(SearchWeatherState.self)
        serviceMock.mockResult = .failure(APIError.badRequest)
        
        let output = viewModel.transform(input: WeatherListViewModelInput(loadView: loadView,
                                                                          search: search))
        output.weatherSearchOutput
            .drive(result)
            .disposed(by: disposeBag)
        
        //When trigger loadview and search
        loadView.accept(())
        search.accept("saigon")
        scheduler.start()
        
        //Then expect output should be three events: init as empty and error
        XCTAssertEqual(result.events.count,2)
        XCTAssertEqual(result.events.compactMap(pullBackToElement),[.empty,.haveError(APIError.badRequest)])
        XCTAssertEqual(serviceMock.parameter?.searchTerm,"saigon")
        XCTAssertEqual(serviceMock.parameter?.unit,"metric")
        XCTAssertEqual(cacheMock.getWeatherKeyHooked,"saigonmetric2.5")
        XCTAssertNil(cacheMock.setWeatherKeyHooked)
        XCTAssertNil(cacheMock.weatherParameterhook)
    }

    //Success but empty
    func testShouldNotMakeDisplayModelWhenResponseInconsistenceData() {
        //Given ViewModel input and mock api with incorect data response
        let loadView = PublishRelay<Void>()
        let search = PublishRelay<String>()
        let result = scheduler.createObserver(SearchWeatherState.self)
        let output = viewModel.transform(input: WeatherListViewModelInput(loadView: loadView,
                                                                          search: search))
        output.weatherSearchOutput
            .drive(result)
            .disposed(by: disposeBag)
        
        //When trigger loadview and multiple search and mock inconsistence WeatherResponse
        let inConsistenceWeatherFactor = WeatherFactor.inConsistenceStub(dt: nil, temp: nil, pressure: nil, humidity: nil, weather: nil)
        loadView.accept(())
        scheduler.createColdObservable([.next(0, ("saigon", WeatherResponseModel.inConsistenceStub())),
                                        .next(5, ("saigon", WeatherResponseModel.inConsistenceStub([]))),
                                        .next(15, ("saigon", WeatherResponseModel.inConsistenceStub([inConsistenceWeatherFactor])))])
            .subscribe { [unowned self] searchTerm, mockReponse in
                self.serviceMock.mockResult = .success(mockReponse)
                search.accept(searchTerm)
            }.disposed(by: disposeBag)

        scheduler.start()
        scheduler.start()
        
        //Then expect output should be trigger all empty result
        XCTAssertEqual(result.events.count,4)
        XCTAssertEqual(result.events.compactMap(pullBackToElement),[.empty,.empty,.empty,.empty])
        XCTAssertEqual(serviceMock.parameter?.searchTerm,"saigon")
        XCTAssertEqual(serviceMock.parameter?.unit,"metric")
    }
    
    //Change config should get other cache
    func testCacheKeyShouldBeCombineOfSearchTermMetricAndCnt() {
        //Given ViewModel input & Mock cache data
        let loadView = PublishRelay<Void>()
        let search = PublishRelay<String>()
        let result = scheduler.createObserver(SearchWeatherState.self)
        
        let output = viewModel.transform(input: WeatherListViewModelInput(loadView: loadView,
                                                                          search: search))
        output.weatherSearchOutput
            .drive(result)
            .disposed(by: disposeBag)
        
        //When trigger loadview and search
        loadView.accept(())
        search.accept("saigon")
        scheduler.start()
        
        //Then expect output should be three events: init as empty, loaded with cache and server response
        XCTAssertEqual(cacheMock.getWeatherKeyHooked,"saigonmetric2.5")
    }
    
    //Clear search term should back to emtpy
    func testShouldClearResultWhenSearchTermIsEmpty() {
        //Given ViewModel input
        let loadView = PublishRelay<Void>()
        let search = PublishRelay<String>()
        let result = scheduler.createObserver(SearchWeatherState.self)
        
        //Bind data to output
        let output = viewModel.transform(input: WeatherListViewModelInput(loadView: loadView,
                                                                          search: search))
        output.weatherSearchOutput
            .drive(result)
            .disposed(by: disposeBag)
        loadView.accept(())
        
        //When trigger multiple search
        scheduler.createColdObservable([.next(0, "Saigon"),.next(5, "")])
            .bind(to: search)
            .disposed(by: disposeBag)
        scheduler.start()
        
        //Then expect just last searchterm be triggered and output should be three even is empty, loaded and empty
        XCTAssertEqual(result.events.count,3)
        XCTAssertEqual(result.events.compactMap(pullBackToElement),[.empty, .loaded([.mockExpected()]),.empty])
    }
    
    
    
}
