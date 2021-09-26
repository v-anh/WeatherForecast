//
//  CacheTests.swift
//  WeatherTests
//
//  Created by Anh Tran on 26/09/2021.
//

import XCTest
import RxSwift
import RxTest

@testable import Weather

class CacheServiceTests: XCTestCase {

    var cacheService: WeatherCacheService!
    var mockCache: CacheMock!
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        mockCache = CacheMock()
        cacheService = WeatherCacheService(mockCache)
    }

    func testCacheserviceShouldInsertToCache() {
        //Given WeatherReponseModel and cache key
        let object = WeatherResponseModel.stub()
        let key = "key"
        
        //When trigger insert to cache
        cacheService.setWeather(object, key: key)
            .subscribe()
            .disposed(by: disposeBag)
        
        //Then
        XCTAssertEqual(mockCache.objectHooked as? WeatherResponseModel, object)
        XCTAssertEqual(mockCache.setKeyHooked, key)
    }
    
    func testCacheserviceShouldGetFromCache() {
        //Given cache key and mocked response from cahce
        let object = WeatherResponseModel.stub()
        let key = "key"
        mockCache.mockReturn = object
        
        //When trigger insert to cache
        let result = scheduler.createObserver(WeatherResponseModel.self)
        cacheService
            .getWeather(key: key)
            .bind(to: result)
            .disposed(by: disposeBag)
        
        //Then
        XCTAssertEqual(result.events.compactMap(pullBackToElement).first, object)
        XCTAssertEqual(mockCache.objectKeyHooked, key)
        XCTAssertTrue(mockCache.typeHooked is WeatherResponseModel.Type)
    }

}
