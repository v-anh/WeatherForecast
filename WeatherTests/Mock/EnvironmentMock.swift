//
//  EnvironmentMock.swift
//  WeatherTests
//
//  Created by Anh Tran on 26/09/2021.
//

import Foundation
@testable import Weather
struct EnvironmentMock: EnvironmentProtocol {
    var headers: [String : String] = [:]
    
    var baseURL: String = "baseURL"
    
    var apiKey: String = "apiKey"
}
