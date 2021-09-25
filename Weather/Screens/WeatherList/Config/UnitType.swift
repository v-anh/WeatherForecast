//
//  Unit.swift
//  Weather
//
//  Created by Anh Tran on 25/09/2021.
//

import Foundation
enum UnitType {
    case Kelvin
    case Celsius
    case Fahrenheit
    
    var parameter: String {
        switch self {
        case .Kelvin:
            return ""
        case .Celsius:
            return "metric"
        case .Fahrenheit:
            return "imperial"
        }
    }
}

extension UnitType {
    var toString: String {
        switch self {
        case .Kelvin:
            return "K"
        case .Celsius:
            return "°C"
        case .Fahrenheit:
            return "°F"
        }
    }
    
}
