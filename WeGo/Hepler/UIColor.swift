//
// Created by Jude on 9/28/17.
// Copyright (c) 2017 org. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    var HexString: String {
        var red:   CGFloat = 0
        var green: CGFloat = 0
        var blue:  CGFloat = 0
        var alpha: CGFloat = 0

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return String(format: "%02X%02X%02X",
                    Int(red * 0xff),
                    Int(green * 0xff),
                    Int(blue * 0xff)
        )
    }
    
    class func appColor() -> UIColor {
        return UIColor.init(hex: "7E5CE8")
    }

    convenience
    init( hex: String ) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let red   = (rgbValue & 0xff0000) >> 16
        let green = (rgbValue & 0xff00) >> 8
        let blue  = rgbValue & 0xff

        self.init(red: CGFloat(red) / 0xff,
                    green: CGFloat(green) / 0xff,
                    blue: CGFloat(blue) / 0xff, alpha: 1
        )
    }
}
