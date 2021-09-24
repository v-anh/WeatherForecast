//
//  XCTestCase+Extension.swift
//  WeatherTests
//
//  Created by Anh Tran on 24/09/2021.
//

import Foundation
import RxSwift
import RxTest
import XCTest
@testable import Weather
extension XCTestCase {
    func pullBackToElement<T>(_ recordedEvent: Recorded<Event<T>>) -> T? {
        return recordedEvent.value.element
    }
}
