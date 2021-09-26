//
//  ImageLoaderTests.swift
//  WeatherTests
//
//  Created by Anh Tran on 26/09/2021.
//

import XCTest
import RxSwift
import RxBlocking

@testable import Weather

class ImageLoaderTests: XCTestCase {
    var disposeBag: DisposeBag!
    var imageLoader: ImageLoader!
    var mockImageCache: MockImageCache!
    var mockEnvironment: EnvironmentMock!
    var imageDownload: MockImageDownload!
    
    override func setUpWithError() throws {
        disposeBag = DisposeBag()
        mockImageCache = MockImageCache()
        imageDownload = MockImageDownload()
        mockEnvironment = EnvironmentMock()
        ImageLoader.setup(ImageLoader.Config(cache: mockImageCache,
                                             downloader: imageDownload))
    }
    
    func testShouldDownloadImageSuccess() {
        //Given image url and size of container and Image Response mock
        let image = UIImage(systemName: "face.smiling")
        imageDownload.mockImageResponse = image
        let imageUrl = URL(string: "https://image.com")!
        let size = CGSize(width: 10, height: 10)
        
        //When trigger download image
        let result = ImageLoader.shared.loadImage(from: imageUrl, size: size)
        
        //Then image download should resize image
        let imageResult = try? result.toBlocking().first()
        XCTAssertEqual(imageResult??.size, CGSize(width: 10, height: 10))
        XCTAssertEqual(imageDownload.callStack, [imageUrl])
    }
    
    
    func testShouldCacheImageWhenDownloadImageSuccess() {
        //Given image url and size of container and Image Response mock
        let image = UIImage(systemName: "face.smiling")
        imageDownload.mockImageResponse = image
        let imageUrl = URL(string: "https://image.com")!
        let size = CGSize(width: 10, height: 10)
        
        //When trigger download image
        let result = ImageLoader.shared.loadImage(from: imageUrl, size: size)
        
        //Then image download cached with key base on url and size
        let imageResult = try? result.toBlocking().first()
        XCTAssertEqual(imageResult??.size, CGSize(width: 10, height: 10))
        XCTAssertEqual(mockImageCache.setImageCallStack, ["https://image.com{10, 10}"])
    }
    
    func testShouldLoadImageFromCacheWhenImageIsAvailabelInCache() {
        //Given Image cached
        mockImageCache.getImageHooked = UIImage(systemName: "face.smiling")?.resize(10)
        let imageUrl = URL(string: "https://image.com")!
        let size = CGSize(width: 10, height: 10)
        
        //When trigger download image
        let result = ImageLoader.shared.loadImage(from: imageUrl, size: size)
        
        //Then should return from cache instead of download
        let imageResult = try? result.toBlocking().first()
        XCTAssertEqual(imageResult??.size, CGSize(width: 10, height: 10))
        XCTAssertEqual(mockImageCache.getImageCallStack, ["https://image.com{10, 10}"])
        XCTAssertTrue(imageDownload.callStack.isEmpty)
    }
    
    func testShouldJustDownloadImageOnceWithSameUrl() {
        //Given image url and size of container and Image Response mock
        let image = UIImage(systemName: "face.smiling")
        imageDownload.mockImageResponse = image
        let imageUrl = URL(string: "https://image.com")!
        let size = CGSize(width: 10, height: 10)
        
        //When trigger download image
        _ = ImageLoader.shared.loadImage(from: imageUrl, size: size)
        _ = ImageLoader.shared.loadImage(from: imageUrl, size: size)
        _ = ImageLoader.shared.loadImage(from: imageUrl, size: size)
        _ = ImageLoader.shared.loadImage(from: imageUrl, size: size)
        
        //Then image download should resize image
        XCTAssertEqual(imageDownload.callStack.count, 1)
    }

}

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

class MockImageDownload: ImageDownloadType {
    var callStack = [URL]()
    var mockImageResponse: UIImage?
    func downloadImage(from url: URL) -> Observable<UIImage?> {
        callStack.append(url)
        return .just(mockImageResponse)
    }
}
