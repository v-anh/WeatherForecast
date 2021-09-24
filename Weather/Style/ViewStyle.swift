//
//  ViewStyle.swift
//  Weather
//
//  Created by Anh Tran on 24/09/2021.
//

import UIKit

public struct ViewStyle<T> {
    private let styling: (T) -> Void
    
    public init(styling: @escaping (T) -> Void) {
        self.styling = styling
    }
    
    public init() {
        styling = { T -> Void in return }
    }
    
    public func apply(to target: T) {
        styling(target)
    }
    
    public func with(_ styling: @escaping (T) -> Void) -> ViewStyle<T> {
        return ViewStyle<T> {
            self.apply(to: $0)
            styling($0)
        }
    }
}
