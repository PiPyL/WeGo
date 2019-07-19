//
//  AlertController.swift
//  FFL
//
//  Created by Jude on 7/12/18.
//  Copyright © 2018 FFL. All rights reserved.
//


import UIKit

class AlertController: NSObject {
    
    typealias ConfirmButtonTapBlock = (_ alert: UIAlertController?, _ action: UIAlertAction?) -> Void
    
    static public func showOptionAlertController(title: String, message: String, _ completionHandler: (( _ alert: UIAlertController, _ action: UIAlertAction) -> Void)?) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: "Hủy", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
            completionHandler?(alert, action)
        }))
        let currentVC = UIViewController.topViewController
        currentVC?.present(alert, animated: true)
    }
    
    static public func showAlertController(title: String, message: String, _ completionHandler: (( _ alert: UIAlertController, _ action: UIAlertAction) -> Void)?) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (action) in
            completionHandler?(alert, action)
        }))
        let currentVC = UIViewController.topViewController
        currentVC?.present(alert, animated: true)
    }
}
