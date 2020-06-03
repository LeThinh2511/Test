//
//  CircleProgressView.swift
//  Test
//
//  Created by Techchain on 6/3/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

@IBDesignable
class CircleProgressView: UIView {
    @IBInspectable var value: Double = 180
    @IBInspectable var valueFontSize: CGFloat = 30
    @IBInspectable var valueColor: UIColor = .red
    
    @IBInspectable var maxValue: Double = 360
    @IBInspectable var fillColor: UIColor = .red
    @IBInspectable var shadowFillColor: UIColor = .gray
    @IBInspectable var shadowFillRadius: CGFloat = 5
    
    @IBInspectable var lowerLineWidth: CGFloat = 8
    @IBInspectable var lowerColor: UIColor = .gray
    
    @IBInspectable var upperLineWidth: CGFloat = 10
    @IBInspectable var upperColor: UIColor = .green
    
    @IBInspectable var circleSize: CGFloat = 14
    @IBInspectable var circleColor: UIColor = .black
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
                let circleSize = min(rect.width, rect.height)
                let circleX = (rect.width - circleSize) / 2
                let circleY = (rect.height - circleSize) / 2
                let circleFrame = CGRect(x: circleX, y: circleY, width: circleSize, height: circleSize)
                
                let radius = (circleSize - upperLineWidth) / 2 - shadowFillRadius
                let outerRadius = radius + upperLineWidth / 2
                let innerRadius = radius - upperLineWidth / 2
                let center = CGPoint(x: circleX + circleSize / 2, y: outerRadius + shadowFillRadius)
    }
}
