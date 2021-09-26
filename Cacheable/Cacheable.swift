//
//  Cacheable.swift
//  Weather
//
//  Created by Anh Tran on 25/09/2021.
//

import Foundation
import RxSwift

enum CacheError: Swift.Error {
    case cache
    case getObject
}
protocol CacheProtocol {
    func set<T:Encodable>(object: T, key: String) -> Observable<Void>
    func get<T:Decodable>(for key: String, type:T.Type) -> Observable<T>
}

final class Cache: CacheProtocol {
    typealias T = Codable
    typealias K = String
    
    public static let shared = Cache()
    
    private init() {}
    
    private let cache = PersistentCache<T, K>(path: "EncodebleCache")
    
    func set<T>(object: T, key: String) -> Observable<Void> where T : Encodable {
        cache.set(object: object, key: key)
    }
    
    func get<T>(for key: String, type:T.Type) -> Observable<T>  where T : Decodable {
        cache.object(for: key, type: type)
    }
    
}
