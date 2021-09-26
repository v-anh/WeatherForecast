//
//  ImageCacheTest.swift
//  WeatherTests
//
//  Created by Anh Tran on 26/09/2021.
//

import XCTest
@testable import Weather
class ImageCacheTest: XCTestCase {

    var imageCache: ImageCache!
    override func setUpWithError() throws {
        imageCache = ImageCache()
    }

    func testShouldCacheImage() {
        //Given Image and key
        let key = "key"
        let image = UIImage(systemName: "face.smiling")!
        //When
        imageCache.setImage(image, key: key)
        //Then image should be valid when get from cache
        XCTAssertNotNil(imageCache.getImage(key:key))
    }
    
    func testShouldNotReturnImageIfNoCacheYet() {
        //Given Image and key
        let key = "key"
        let image = UIImage(systemName: "face.smiling")!
        //When
        imageCache.setImage(image, key: key)
        //Then image should be valid when get from cache
        XCTAssertNil(imageCache.getImage(key:"newKey"))
    }

}
