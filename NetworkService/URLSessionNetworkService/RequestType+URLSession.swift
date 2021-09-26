//
//  RequestType+URLSession.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//
import Foundation
extension RequestType {
    public func urlRequest(with environment: EnvironmentProtocol) -> URLRequest? {
        guard let url = url(with: environment) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        return request
    }
    private func url(with environment: EnvironmentProtocol) -> URL? {
        guard var urlComponents = URLComponents(string: environment.baseURL) else {
            return nil
        }
        urlComponents.path = urlComponents.path + path
        urlComponents.queryItems = queryItems
        urlComponents.queryItems?.append(URLQueryItem(name: "appid",
                                                      value: environment.apiKey))
        return urlComponents.url
    }
    
    /// Returns the URLRequest `URLQueryItem`
    private var queryItems: [URLQueryItem]? {
        guard method == .get else {
            return nil
        }
        return parameters.map { (key: String, value: CustomStringConvertible) -> URLQueryItem in
            return URLQueryItem(name: key, value: value.description)
        }
    }
}
