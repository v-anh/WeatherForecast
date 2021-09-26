//
//  Cache.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//
import Foundation
import RxSwift

final class PersistentCache<T,K:Hashable> {
    
    private let path: String
    private let cacheScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "EncodebleCache.queue")
    init(path: String) {
        self.path = path
    }
    func set<T>(object: T, key: K) -> Observable<Void> where T : Encodable {
        return Observable.create { observer -> Disposable in
            guard let url = self.directoryURL() else {
                return Disposables.create()
            }
            let path = url.appendingPathComponent("\(key).json")
            self.createDirectoryIfNeeded(at: url)
            do {
                let data = try JSONEncoder().encode(object)
                try data.write(to: path)
                observer.onNext(())
            } catch {
                observer.onError(CacheError.cache)
            }
            
            return Disposables.create()
        }.subscribe(on: cacheScheduler)
    }
    
    func object<T>(for key: String, type:T.Type) -> Observable<T> where T : Decodable {
        Observable<T>.create { observer -> Disposable in
            guard let url = self.directoryURL() else {
                return Disposables.create()
            }
            let path = url.appendingPathComponent("\(key).json")
            do {
                let data = try Data(contentsOf: path)
                let decodedData = try JSONDecoder().decode(type.self, from: data)
                observer.onNext(decodedData)
            } catch {
                observer.onError(CacheError.cache)
            }
            return Disposables.create()
        }
    }
    
    private func directoryURL() -> URL? {
        return FileManager.default
            .urls(for: .documentDirectory,
                  in: .userDomainMask)
            .first?
            .appendingPathComponent(path)
    }
    
    private func createDirectoryIfNeeded(at url: URL) {
        do {
            try FileManager.default.createDirectory(at: url,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
            print("Cache Error createDirectoryIfNeeded \(error)")
        }
    }
}
