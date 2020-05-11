//
//  UIViewExtension.swift
//  Test
//
//  Created by Techchain on 5/7/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import Foundation
import UIKit

typealias Gradient = (color: UIColor, location: Float)
extension UIView {
    func setGradients(gradients: [Gradient], angle: Int = 0) {
        let tanValue = tan(Double(angle) * Double.pi / 180)
        
        let p1 = CGPoint(x: 0.5, y: 0.5)
        let p2y: Double = 0
        let p2x = 0.5 - (0.5 / tanValue)
        let p2 = CGPoint(x: p2x, y: p2y)
        
        // Default x value
        var startX: CGFloat = 0
        var endX: CGFloat = 1
        
        // Direction vector
        let vx = p2.x - p1.x
        let vy = p2.y - p1.y
        
        // Calculate y value
        let dental1 = -0.5 / vx
        var startY = 0.5 + vy * dental1
        let dental2 = 0.5 / vx
        var endY = 0.5 + vy * dental2
        
        // Case angle is multiple of 90 degree
        if (angle - 90) % 180 == 0 {
            startX = 0
            startY = 0
            endX = 0
            endY = 1
        }
        
        var colors = [CGColor]()
        var locations = [NSNumber]()
        for gradient in gradients {
            colors.append(gradient.color.cgColor)
            locations.append(NSNumber(value: gradient.location))
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: startX, y: startY)
        gradientLayer.endPoint = CGPoint(x: endX, y: endY)
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    var maskedCorners: CACornerMask {
        set {
            layer.maskedCorners = newValue
            for layer in layer.sublayers ?? [] {
                layer.maskedCorners = newValue
            }
        }
        
        get {
            return layer.maskedCorners
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            for layer in layer.sublayers ?? [] {
                layer.cornerRadius = newValue
            }
        }
    }
    
    @IBInspectable
    var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
//    @IBInspectable
//    var borderColor: UIColor? {
//        get {
//            if let color = layer.borderColor {
//                return UIColor(cgColor: color)
//            }
//            return nil
//        }
//        set {
//            if let color = newValue {
//                layer.borderColor = color.cgColor
//            } else {
//                layer.borderColor = nil
//            }
//        }
//    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}
