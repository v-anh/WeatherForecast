//
//  WeatherDisplayModel.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
public struct WeatherDisplayModel {
    let date: TimeInterval
    let averageTemp: Float
    let pressure: Double
    let humidity: Double
    let description: String
    let iconUrl: URL
    let unitType: UnitType
}
extension WeatherDisplayModel: Hashable {
    public static func == (lhs: WeatherDisplayModel, rhs: WeatherDisplayModel) -> Bool {
        return lhs.date == rhs.date &&
        lhs.averageTemp == rhs.averageTemp &&
        lhs.pressure == rhs.pressure &&
        lhs.humidity == rhs.humidity &&
        lhs.description == rhs.description &&
        lhs.iconUrl == rhs.iconUrl &&
        lhs.unitType.toString == rhs.unitType.toString
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(averageTemp)
        hasher.combine(pressure)
        hasher.combine(humidity)
        hasher.combine(description)
        hasher.combine(iconUrl)
        hasher.combine(unitType.toString)
    }
}
