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

protocol ImageLoaderType {
    func loadImage(from url: URL, size: CGSize) -> Observable<UIImage?>
}
public final class ImageLoader: NSObject {
    public static let shared = ImageLoader()

    private let cache: ImageCacheType
    private let queue = DispatchQueue(label: "ImageLoader")
    private var observableCache = [URL:Observable<UIImage?>]()
    public init(cache: ImageCacheType = ImageCache()) {
        self.cache = cache
        super.init()
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
        let imageDownload =  URLSession.shared.rx.data(request: URLRequest(url: url))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .map { [weak self ] data -> UIImage? in
                let image = UIImage(data: data)?.resize(size.width)
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

