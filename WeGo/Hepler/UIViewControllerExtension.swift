//
//  UIApplicationExtension.swift
//  FFL
//
//  Created by Jude on 7/12/18.
//  Copyright © 2018 FFL. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    static var topViewController: UIViewController? {
        return TopViewController()
    }
    
    static func TopViewController( of viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController ) -> UIViewController? {
        if let viewController = viewController as? UIPageViewController {
            return TopViewController(of: viewController.viewControllers?.first)
        }
        
        if let viewController = viewController as? UINavigationController {
            return TopViewController(of: viewController.visibleViewController)
        }
        
        if let viewController = viewController as? UITabBarController {
            if let viewController = viewController.selectedViewController {
                return TopViewController(of: viewController)
            }
        }
        
        if let viewController = viewController?.presentedViewController {
            return TopViewController(of: viewController)
        }
        
        return viewController
    }
}


