//
//  NetworkServiceType.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
import RxSwift
public typealias APIResponse<T> = Result<T, APIError>
public protocol NetworkServiceType {
    var environment: EnvironmentProtocol {get}
    func request<T:Decodable>(_ request: RequestType, type: T.Type) -> Observable<APIResponse<T>>
}
