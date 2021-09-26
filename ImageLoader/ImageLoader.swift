//
//  ImageLoader.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
import UIKit
import RxSwift

public protocol ImageCacheType {
    func setImage(_ image: UIImage, key: String)
    func getImage(key: String) -> UIImage?
}

public final class ImageCache: ImageCacheType {
    
    private let imageCache = NSCache<NSString,UIImage>()
    
    public init(){}
    
    public func setImage(_ image: UIImage, key: String) {
        imageCache.setObject(image, forKey: NSString(string: key))
    }
    
    public func getImage(key: String) -> UIImage? {
        return imageCache.object(forKey: NSString(string: key))
    }
}

protocol ImageDownloadType {
    func downloadImage(from url: URL) -> Observable<UIImage?>
}

class URLSessionImageDownload: ImageDownloadType {
    let urlSession: URLSession
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    func downloadImage(from url: URL) -> Observable<UIImage?> {
        return urlSession.rx.data(request: URLRequest(url: url))
            .map { UIImage(data: $0) }
    }
}

protocol ImageLoaderType {
    func loadImage(from url: URL, size: CGSize) -> Observable<UIImage?>
}


public final class ImageLoader: NSObject, ImageLoaderType {
    static var shared: ImageLoader {
        if let initializedShared = _shared {
            return initializedShared
        }
        fatalError("Singleton not yet initialized. Run setup(_ config:Config) first")
    }
    
    public struct Config {
        let cache: ImageCacheType
        let downloader: ImageDownloadType
        
        static let `default` = {
            Config(cache: ImageCache(), downloader: URLSessionImageDownload())
        }
    }
    
    public class func setup(_ config:Config) {
        _shared = ImageLoader(config.cache,
                              downloader: config.downloader)
    }
    
    private var cache: ImageCacheType
    private var downloader: ImageDownloadType
    private let queue = DispatchQueue(label: "ImageLoader")
    private var observableCache = [URL:Observable<UIImage?>]()
    private static var _shared: ImageLoader?
    
    private init(_ cache: ImageCacheType,
                 downloader: ImageDownloadType) {
        self.cache = cache
        self.downloader = downloader
    }
    
    public func loadImage(from url: URL, size: CGSize) -> Observable<UIImage?> {
        if let image = cache.getImage(key: makeCacheKey(url, size: size)) {

            print("cached from last download \(url)")
            return .just(image)
        }

        if let publisher = observableCache[url] {
            print("reuse form last download \(url)")
            return publisher
        }
        print("start download \(url), \(size)")
        let imageDownload =  self.downloader.downloadImage(from: url)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .map { [weak self ] image -> UIImage? in
                let image = image?.resize(size.width)
                if let self = self,
                   let image = image {
                    self.cache.setImage(image, key: self.makeCacheKey(url, size: size))
                }
                return image
            }.share()
            .subscribe(on: MainScheduler.instance)
        observableCache[url] = imageDownload
        return imageDownload
    }
    
    private func makeCacheKey(_ url: URL, size: CGSize) -> String {
        return url.absoluteString + NSCoder.string(for: size)
    }
}

