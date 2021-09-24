//
//  File.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
public protocol Cacheable {
    func setObject<T:Decodable>(_ object: T, forKey key: URL)
    func object<T:Decodable>(ofType type: T.Type, forKey key: URL) -> T?
}

public struct URLResponseCache: Cacheable{
    
    static let `default` = {
        URLResponseCache(dateProvider: {
                            Date.init()
        },lifeTime: 100)
    }()
    
    private let cache: Cache<URL,Decodable>
    
    init(dateProvider: @escaping () -> Date = Date.init, lifeTime:TimeInterval) {
        cache = Cache<URL,Decodable>(.expirable(lifeTime),
                                            currentDate: dateProvider)
    }

    public func setObject<T:Decodable>(_ object: T, forKey key: URL) {
        cache.insert(object, forKey: key)
    }
    
    public func object<T:Decodable>(ofType type: T.Type, forKey key: URL) -> T? {
        cache.value(forKey: key) as? T
    }
}
