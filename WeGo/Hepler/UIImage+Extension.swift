//
//  UIImage+Extension.swift
//  EventTinder
//
//  Created by Fu' on 9/15/18.
//  Copyright © 2018 PartyApp. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import FirebaseStorage

extension UIImage {
    
    func uploadImage(completionHandler: @escaping (_ avatarURL: String, _ error: Error?) -> ()) {
        SVProgressHUD.show()
        let imageName = UUID().uuidString
        let storage = Storage.storage().reference().child("message").child(imageName)
        

        if let uploadData = self.jpegData(compressionQuality: 0.75) {
            storage.putData(uploadData, metadata: nil, completion: { (meta, error) in
                if error == nil {
                    storage.downloadURL(completion: { (urlImage, error) in
                        SVProgressHUD.dismiss()
                        if urlImage != nil {
                            completionHandler((urlImage?.absoluteString)!, nil)
                        } else {
                            completionHandler("", error)
                        }
                    })
                } else {
                    SVProgressHUD.dismiss()
                    completionHandler("", error)
                }
            })
        }
    }
    
    func uploadAvatar(completionHandler: @escaping (_ avatarURL: String, _ error: Error?) -> ()) {
        SVProgressHUD.show()
        
        if let user = AppDataSingleton.sharedInstance.currentUser {
            let storage = Storage.storage().reference().child("avatar").child(user.getEmailRef())
            
            if let uploadData = self.jpegData(compressionQuality: 0.75) {
                storage.putData(uploadData, metadata: nil, completion: { (meta, error) in
                    if error == nil {
                        storage.downloadURL(completion: { (urlImage, error) in
                            SVProgressHUD.dismiss()
                            if urlImage != nil {
                                completionHandler((urlImage?.absoluteString)!, nil)
                            } else {
                                completionHandler("", error)
                            }
                        })
                    } else {
                        SVProgressHUD.dismiss()
                        completionHandler("", error)
                    }
                })
            }
        }
    }
    
//    class func imageWithImage(image: UIImage) -> UIImage {
//        let bubbleImage = image.resizableImage(withCapInsets: UIEdgeInsetsMake(image.size.height/2, image.size.width/2, image.size.height/2, image.size.width/2), resizingMode: .stretch)
//        return bubbleImage
//    }
//
//    class func imageWithURL(url: String) -> UIImage{
//        var avatarImage = UIImage.init()
//        let avatarImageView = UIImageView.init()
//        if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: url) {
//           avatarImage = image
//        } else {
//            let resource = ImageResource(downloadURL: URL(string: url)!, cacheKey: url)
//            avatarImageView.kf.setImage(with: resource, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
//                if image != nil {
//                    avatarImage = image!
//                }
//            }
//        }
//        return avatarImage
//    }
}
