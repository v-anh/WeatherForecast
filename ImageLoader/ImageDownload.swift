//
//  ImageDownload.swift
//  Weather
//
//  Created by Anh Tran on 26/09/2021.
//

import UIKit
import RxSwift
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
