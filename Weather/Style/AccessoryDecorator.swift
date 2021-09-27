//
//  AccessoryDecorator.swift
//  Weather
//
//  Created by Anh Tran on 24/09/2021.
//

import UIKit


/// AccessoryDecorator: Abstract protocol to add inject Accessory
protocol AccessoryDecorator {
    associatedtype Target
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
