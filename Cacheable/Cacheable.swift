//
//  Cacheable.swift
//  Weather
//
//  Created by Anh Tran on 25/09/2021.
//

import Foundation
import RxSwift

enum CacheError: Swift.Error {
    case insert
    case getObject
}
protocol CacheProtocol {
    associatedtype T
    associatedtype K
    func insert<T:Encodable>(object: T, key: K) -> Observable<Void>
    func object<T:Decodable>(for key: String, type:T.Type) -> Observable<T>
}

final class Cache: CacheProtocol {
    typealias T = Codable
    typealias K = String
    
    public static let shared = Cache()
    
    private init() {}
    
    private let cache = PersistentCache<T, K>(path: "EncodebleCache")
    
    func insert<T>(object: T, key: String) -> Observable<Void> where T : Encodable {
        cache.insert(object: object, key: key)
    }
    
    func object<T>(for key: String, type:T.Type) -> Observable<T>  where T : Decodable {
        cache.object(for: key, type: type)
    }
    
}
