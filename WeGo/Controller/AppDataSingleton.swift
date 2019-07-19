//
//  AppDataSingleton.swift
//  FFL
//
//  Created by Jude on 9/11/18.
//  Copyright © 2018 FFL. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

enum Defaults {
    static func set(_ object: Any, forKey defaultName: String) {
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(object, forKey:defaultName)
        defaults.synchronize()
        
    }
    static func object(forKey key: String) -> AnyObject! {
        let defaults: UserDefaults = UserDefaults.standard
        return defaults.object(forKey: key) as AnyObject?
    }
}

class AppDataSingleton: NSObject {
    
    static let sharedInstance = AppDataSingleton()
    
    var currentUser: UserModel? {
        get {
            let currentUserDict = Defaults.object(forKey: "CurrentUserModel") as? [String : Any]
            if currentUserDict == nil {
                return nil
            }
            
            if (currentUserDict?.count) != 0 {
                return UserModel.init(fromDictionary: currentUserDict!)
            }
            return nil
        }
        
        set(currentUser) {
            if currentUser != nil {
                let currentUserDict = currentUser?.toDictionary()
                Defaults.set(currentUserDict!, forKey: "CurrentUserModel")
            } else {
                Defaults.set([:], forKey: "CurrentUserModel")
            }
        }
    }
    
    var endAddressDefault: Address? {
        get {
            let endAddressDefaultDict = Defaults.object(forKey: "EndAddressDefault") as? [String : Any]
            if endAddressDefaultDict == nil {
                return nil
            }
            
            if (endAddressDefaultDict?.count) != 0 {
                return Address.init(fromDictionary: endAddressDefaultDict!)
            }
            return nil
        }
        
        set(endAddressDefault) {
            if endAddressDefault != nil {
                let endAddressDefaultDict = endAddressDefault?.toDictionary()
                Defaults.set(endAddressDefaultDict!, forKey: "EndAddressDefault")
            } else {
                Defaults.set([:], forKey: "EndAddressDefault")
            }
        }
    }
    
    var startAddressDefault: Address? {
        get {
            let startAddressDefaultDict = Defaults.object(forKey: "StartAddressDefault") as? [String : Any]
            if startAddressDefaultDict == nil {
                return nil
            }
            
            if (startAddressDefaultDict?.count) != 0 {
                return Address.init(fromDictionary: startAddressDefaultDict!)
            }
            return nil
        }
        
        set(startAddressDefault) {
            if startAddressDefault != nil {
                let startAddressDefaultDict = startAddressDefault?.toDictionary()
                Defaults.set(startAddressDefaultDict!, forKey: "StartAddressDefault")
            } else {
                Defaults.set([:], forKey: "StartAddressDefault")
            }
        }
    }
    
    var ref: DatabaseReference!
    
    override init() {
        super.init()
        ref = Database.database().reference()
    }
}
