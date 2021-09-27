//
//  NetworkServiceType.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
import RxSwift
public typealias APIResponse<T> = Result<T, APIError>

/// NetworkServiceType is a protocol provide ability to request Server API following RequestType
public protocol NetworkServiceType {
    var environment: EnvironmentProtocol {get}
    
    
    /// Make request to server
    /// - Parameters:
    ///   - request: RequestType
    ///   - type: Decodable Type
    func request<T:Decodable>(_ request: RequestType, type: T.Type) -> Observable<APIResponse<T>>
}
