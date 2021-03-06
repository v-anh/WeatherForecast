//
//  WeatherRequest.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
struct WeatherRequest:RequestType {
    let searchTerm: String
    let units: String
    let cnt:Float
    var path: String {
        "data/\(cnt)/forecast/daily"
    }
    var method: Method {
        .get
    }
    
    var headers: [String : String] { [:] }
    
    var parameters: [String : CustomStringConvertible] {
        ["q":searchTerm,
         "units":units]
    }
}
