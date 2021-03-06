//
//  Decodeable+Extension.swift
//  WeatherTests
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
@testable import Weather
extension Decodable {
    static func loadFromFile(_ filename: String) -> Self {
        do {
            let path = Bundle(for: WeatherListViewModelTests.self).path(forResource: filename, ofType: "json")!
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            return try JSONDecoder().decode(Self.self, from: data)
        } catch {
            fatalError("Error: \(error)")
        }
    }
}
