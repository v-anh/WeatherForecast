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
    var mainScheduler: SchedulerType = MainScheduler.instance
    var unit: String  = "metric"
}
class WeatherListViewModelTests: XCTestCase {

    var viewModel: WeatherListViewModel!
    var serviceMock: WeatherServiceMock!
    var config: WeatherConfigMock!
    var scheduler: TestScheduler!

    var disposeBag: DisposeBag!
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        serviceMock = WeatherServiceMock()
        config = WeatherConfigMock()
        config.mainScheduler = scheduler
        viewModel = WeatherListViewModel(service: serviceMock, config: config)
    }
    
    override func tearDown() {
        scheduler = nil
        viewModel = nil
        disposeBag = nil
    }
    
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
        output.weatherSearchOutput.debug("v-anh", trimOutput: false)
            .drive(result)
            .disposed(by: disposeBag)
        
        //When trigger loadview and search
        loadView.accept(())
        search.accept("saigon")
        scheduler.start()
        
        //Then expect output should be empty state and just one event emitted
        XCTAssertEqual(result.events.count,2)
        XCTAssertEqual(result.events.compactMap(pullBackToElement),[.empty,.loaded([.mockExpected()])])
        XCTAssertEqual(serviceMock.searchTerm,"saigon")
        XCTAssertEqual(serviceMock.units,"metric")
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
    
    func testShouldDebounceBeforeTriggerSearchTearm() {
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
        XCTAssertEqual(serviceMock.searchTerm,"Saigon")
        XCTAssertEqual(serviceMock.units,"metric")
    }
}
