//
//  UIStoryboardExtension.swift
//  EventTinder
//
//  Created by mac on 9/12/18.
//  Copyright © 2018 PartyApp. All rights reserved.
//
import Foundation
import UIKit

extension UIStoryboard {
    
    class func mainStoryboard()->UIStoryboard {
        return UIStoryboard.init(name: "Main", bundle: nil)
    }
    
    class func authenticationStoryboard()->UIStoryboard {
        return UIStoryboard.init(name: "Authentication", bundle: nil)
    }
    
    class func accountStoryboard()->UIStoryboard {
        return UIStoryboard.init(name: "Account", bundle: nil)
    }
    
    class func filterStoryboard()->UIStoryboard {
        return UIStoryboard.init(name: "Filter", bundle: nil)
    }
    
    class func joinedStoryboard()->UIStoryboard {
        return UIStoryboard.init(name: "Joined", bundle: nil)
    }
    
    class func storyStoryboard()->UIStoryboard {
        return UIStoryboard.init(name: "Story", bundle: nil)
    }
}
