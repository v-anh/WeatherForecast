//
//  ImageCache.swift
//  Weather
//
//  Created by Anh Tran on 26/09/2021.
//

import Foundation
import UIKit

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
