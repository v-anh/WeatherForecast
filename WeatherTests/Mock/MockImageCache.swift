//
//  MockImageCache.swift
//  WeatherTests
//
//  Created by Anh Tran on 26/09/2021.
//

import UIKit
@testable import Weather
class MockImageCache: ImageCacheType {
    var setImageCallStack = [String]()
    var setImageHooked: UIImage?
    func setImage(_ image: UIImage, key: String) {
        setImageHooked = image
        setImageCallStack.append(key)
    }
    
    var getImageHooked: UIImage?
    var getImageCallStack = [String]()
    func getImage(key: String) -> UIImage? {
        getImageCallStack.append(key)
        return getImageHooked
    }
}
