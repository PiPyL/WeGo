//
//  UIView+Extension.swift
//  FFL
//
//  Created by Jude on 9/14/18.
//  Copyright © 2018 FFL. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    static func fromNib( ) -> Self {
        func impl<Type:UIView>( type: Type.Type ) -> Type {
            return Bundle.main.loadNibNamed(String(describing: type), owner: nil, options: nil)!.first as! Type
        }
        
        return impl(type: self)
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
