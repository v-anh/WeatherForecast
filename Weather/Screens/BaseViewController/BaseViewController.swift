//
//  BaseViewController.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import Foundation
import UIKit
class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showError(_ message: String) {
        let alertController = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        alertController.view.accessibilityIdentifier = "alertController"
        let alertAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}
