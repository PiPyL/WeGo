//
//  String+Extension.swift
//  FFL
//
//  Created by Jude on 9/13/18.
//  Copyright © 2018 FFL. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func contains(_ find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    func isValidEmail()-> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func dayFormat() -> NSMutableAttributedString {
        let font:UIFont? = UIFont(name: "Helvetica", size:14)
        let fontSuper:UIFont? = UIFont(name: "Helvetica", size:10)
        let string = self + getSubString()
        let offset = string.count - 2
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: [.font:font!])
        attString.setAttributes([.font:fontSuper!,.baselineOffset:6], range: NSRange(location:offset,length:2))
        return attString
    }
    
    private func getSubString() -> String{
        if self == "1" {
            return "ST"
        }
        if self == "2" {
            return "ND"
        }
        return "TH"
    }
}
