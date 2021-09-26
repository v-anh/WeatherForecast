//
//  PersistentCacheTests.swift
//  WeatherTests
//
//  Created by Anh Tran on 26/09/2021.
//

import XCTest
import RxSwift
import RxTest
@testable import Weather
class PersistentCacheTests: XCTestCase {
    
    var cache: PersistentCache<Codable,String>!
    var path : String = "TestCache"
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        cache = PersistentCache(path: path)
    }
    
    func testCacheShouldInsertObjectWithFollowingKey() {
        //Given codable object and key
        let object = WeatherResponseModel.stub()
        let key = "key"
        
        //When trigger cache object
        cache.set(object: object, key: key)
            .subscribe()
            .disposed(by: disposeBag)
        
        //Then Object shoulf be store in Document folder
        let documentPath = self.directoryURL(path)
        let data = try? Data(contentsOf: (documentPath?.appendingPathComponent("key.json"))!)
        XCTAssertNotNil(data)
        if let data = data,
           let decodedData = try? JSONDecoder().decode(WeatherResponseModel.self, from: data) {
            XCTAssertEqual(decodedData, object)
        }
    }
    
    func testCacheShouldGetCorrectObject() {
        //Given object is stored in the Document Directory
        let key = "key"
        let object = WeatherResponseModel.stub()
        let path = self.directoryURL(path)?.appendingPathComponent("\(key).json")
        if let path = path,
           let data = try? JSONEncoder().encode(WeatherResponseModel.stub()) {
            try? data.write(to: path)
        }
        //When trigger get object from cache
        let result = scheduler.createObserver(WeatherResponseModel.self)
        cache.object(for: key, type: WeatherResponseModel.self)
            .bind(to: result)
            .disposed(by: disposeBag)
        
        //Then cache should return correct data in the Document Directory
        XCTAssertEqual(result.events.compactMap(pullBackToElement).first, object)
    }
    
    func testCacheShouldEmitErrorWhenDataUnavailabelInDocument() {
        //Given object is stored in the Document Directory
        let key = "unavailabelKey"
        //When trigger get object from cache
        let result = scheduler.createObserver(WeatherResponseModel.self)
        cache.object(for: key, type: WeatherResponseModel.self)
            .bind(to: result)
            .disposed(by: disposeBag)
        
        //Then cache should return CacheError
        let error = result.events.first?.value.error
        XCTAssertNotNil(result.events.first?.value.error as? CacheError)
        if case CacheError.cache? = (error as? CacheError) {
            XCTAssertTrue(true)
        }else{
            XCTAssertTrue(false)
        }
    }
}


extension PersistentCacheTests {
    func directoryURL(_ path: String) -> URL? {
        return FileManager.default
            .urls(for: .documentDirectory,
                  in: .userDomainMask)
            .first?
            .appendingPathComponent(path)
    }
}
