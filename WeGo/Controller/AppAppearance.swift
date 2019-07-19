//
//  AppAppearance.swift
//  Line Hop
//
//  Created by Dung Nguyen on 10/27/15.
//  Copyright © 2015 AppsCyclone. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class AppAppearance {
    
    static func setAppAppearance() {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16, weight: .semibold)];
        
        UINavigationBar.appearance().backIndicatorImage = UIImage.init(named: "ic_back")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage.init(named: "ic_back")
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: UIBarMetrics.default)
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.init(hex: "5ca2d6")
        UINavigationBar.appearance().shadowImage = UIImage()
//        UITabBar.appearance().layer.borderWidth = 0.0
//        UITabBar.appearance().layer.borderColor = UIColor.clear.cgColor
//        UITabBar.appearance().clipsToBounds = true
//        UITabBar.appearance().isTranslucent = false
//        UITabBar.appearance().shadowImage = .init()
//        UITabBar.appearance().backgroundImage = .init()
        SVProgressHUD.setForegroundColor(UIColor.init(hex: "5ca2d6"))
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
    }
}


