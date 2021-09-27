//
//  ImageLoader.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
import UIKit
import RxSwift


/// ImageLoader
protocol ImageLoaderType {
    
    /// Load Image from Url with Cache
    /// - Parameters:
    ///   - url: Image Url
    ///   - size: Size of Image container
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

            return .just(image)
        }

        if let publisher = observableCache[url] {
            return publisher
        }
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

