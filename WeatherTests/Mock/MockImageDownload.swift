//
//  MockImageDownload.swift
//  WeatherTests
//
//  Created by Anh Tran on 26/09/2021.
//

import UIKit
import RxSwift

@testable import Weather
class MockImageDownload: ImageDownloadType {
    var callStack = [URL]()
    var mockImageResponse: UIImage?
    func downloadImage(from url: URL) -> Observable<UIImage?> {
        callStack.append(url)
        return .just(mockImageResponse)
    }
}
