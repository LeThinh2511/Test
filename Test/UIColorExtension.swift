//
//  UIColorExtension.swift
//  Test
//
//  Created by Techchain on 5/7/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static func RGB(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: alpha)
    }
    
    static func hex(_ hex: String) -> UIColor {
        var string: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (string.hasPrefix("#")) {
            string.remove(at: string.startIndex)
        }

        if (string.count != 6) {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: string).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
