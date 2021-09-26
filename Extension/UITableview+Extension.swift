//
//  UITableview+Extension.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import UIKit
extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0,
                                                 width: self.bounds.size.width,
                                                 height: self.bounds.size.height))
        
        ViewStyle<UILabel>().with {
            $0.text = message
            $0.textColor = .black
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.sizeToFit()
            $0.font = .preferredFont(forTextStyle: .body)
            $0.adjustsFontForContentSizeCategory = true
        }.apply(to: messageLabel)
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
