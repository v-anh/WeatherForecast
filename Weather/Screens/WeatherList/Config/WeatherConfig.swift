//
//  WeatherConfig.swift
//  Weather
//
//  Created by Anh Tran on 25/09/2021.
//

import Foundation
import RxSwift
protocol WeatherConfigType {
    var unit: Unit {get}
    var cnt: Float {get}
    var mainScheduler: SchedulerType {get}
}

struct WeatherConfig: WeatherConfigType {
    var cnt: Float {
        return 2.5
    }
    var unit: Unit {
        Unit.Celsius
    }
    var mainScheduler: SchedulerType {
        MainScheduler.instance
    }
}
