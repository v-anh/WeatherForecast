//
//  CacheMock.swift
//  WeatherTests
//
//  Created by Anh Tran on 26/09/2021.
//

import Foundation
import RxSwift
@testable import Weather
class CacheMock: CacheProtocol {
    var objectHooked: Encodable?
    var setKeyHooked: String?
    func set<T>(object: T, key: String) -> Observable<Void> where T : Encodable {
        objectHooked = object
        setKeyHooked = key
        return .just(())
    }
    
    var typeHooked: Decodable.Type?
    var objectKeyHooked: String?
    var mockReturn: WeatherResponseModel!
    func get<T>(for key: String, type: T.Type) -> Observable<T> where T : Decodable {
        objectKeyHooked = key
        typeHooked = type
        return .just(mockReturn as! T)
    }
}
