//
//  MockURLProtocol.swift
//  WeatherTests
//
//  Created by Anh Tran on 26/09/2021.
//

import Foundation
@testable import Weather

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    override class func canInit(with request: URLRequest) -> Bool {
      return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }
      
    override func startLoading() {
      guard let handler = MockURLProtocol.requestHandler else {
        return
      }
        
      do {
        let (response, data) = try handler(request)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        if let data = data {
          client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
      } catch {
        client?.urlProtocol(self, didFailWithError: error)
      }
    }

    override func stopLoading() {
    }
}

extension MockURLProtocol {
    static var mockSuccess:((URLRequest) throws -> (HTTPURLResponse, Data?)) {
        return  { request in
            let data = try? JSONEncoder().encode(WeatherResponseModel.stub())
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, data)
        }
    }
    
    static func mockFailure(code: Int) -> ((URLRequest) throws -> (HTTPURLResponse, Data?)) {
        return  { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, nil)
        }
    }
}
