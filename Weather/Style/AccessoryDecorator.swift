//
//  AccessoryDecorator.swift
//  Weather
//
//  Created by Anh Tran on 24/09/2021.
//

import Foundation
protocol AccessoryDecorator {
    associatedtype Target
    var label: String { get }
    var hint: String { get }
    @discardableResult
    func apply(to target: Target) -> Target
}
struct Accessibility:AccessoryDecorator  {
    typealias Target = NSObject
    let label: String
    let hint: String
    let trails : UIAccessibilityTraits
    @discardableResult
    func apply(to target: Target) -> Target {
        target.isAccessibilityElement = true
        target.accessibilityHint = hint
        target.accessibilityLabel = label
        target.accessibilityTraits = trails
        return target
    }
}
