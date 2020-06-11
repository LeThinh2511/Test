//
//  OBDMeterView.swift
//  Test
//
//  Created by Techchain on 5/29/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class OBDMeterView: UIView {
    @IBInspectable var unit: String = "Degree"
    @IBInspectable var unitFontSize: CGFloat = 14
    @IBInspectable var unitColor: UIColor = .red
    
    @IBInspectable var name: String = "Azimuth"
    @IBInspectable var nameFontSize: CGFloat = 17
    @IBInspectable var nameColor: UIColor = .red
    
    @IBInspectable var value: Double = 180
    @IBInspectable var valueFontSize: CGFloat = 30
    @IBInspectable var valueColor: UIColor = .red
    @IBInspectable var valueRounded: Bool = false
    
    @IBInspectable var maxValue: Double = 360
    @IBInspectable var lowerLineWidth: CGFloat = 8
    @IBInspectable var lowerColor: UIColor = .gray
    
    @IBInspectable var upperLineWidth: CGFloat = 10
    @IBInspectable var upperColor: UIColor = .green
    
    @IBInspectable var lineShadowColor: UIColor = .gray
    @IBInspectable var lineShadowRadius: CGFloat = 5
    
    private let startAngle = CGFloat(0.75 * Double.pi)
    private let endAngle = CGFloat(0.25 * Double.pi)
    private let bottomAngle = CGFloat(0.5 * Double.pi)
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
//        let circleHeight = rect.height
        let circleSize = min(rect.width, rect.height)
        let circleX = (rect.width - circleSize) / 2
//        let circleY: CGFloat = 0
//        let circleFrame = CGRect(x: circleX, y: circleY, width: circleWidth, height: circleHeight)
        
        let radius = (circleSize - upperLineWidth) / 2 - lineShadowRadius
        let outerRadius = radius + upperLineWidth / 2
//        let innerRadius = radius - upperCircleWidth / 2
        let center = CGPoint(x: circleX + circleSize / 2, y: outerRadius + lineShadowRadius)
        
        // Lower Line
        let lowerLinePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        lowerLinePath.lineCapStyle = .round
        lowerLinePath.lineWidth = lowerLineWidth
        lowerColor.setStroke()
        lowerLinePath.stroke()
        
        // Upper Line
        let shadowOffset = CGSize(width: 0, height: 0)
        var upperEndAngle: CGFloat = 0
        if maxValue != 0 {
            upperEndAngle = startAngle + CGFloat(value / maxValue * (2 * Double.pi - Double(bottomAngle)))
        }
        let upperLinePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: upperEndAngle, clockwise: true)
        context.saveGState()
        context.setShadow(offset: shadowOffset, blur: lineShadowRadius, color: lineShadowColor.cgColor)
        upperLinePath.lineCapStyle = .round
        upperLinePath.lineWidth = upperLineWidth
        upperColor.setStroke()
        upperLinePath.stroke()
        context.restoreGState()
        
        // Value Label
        let valueFont: UIFont = .systemFont(ofSize: valueFontSize)
        let valueTitle = valueRounded ? "\(Int(value))" : "\(value)"
        let valueTitleSize = valueTitle.sizeOf(valueFont)
        let valueTitleY = center.y - valueTitleSize.height
        let valueTitleX = center.x - valueTitleSize.width / 2
        let valueTitleOrigin = CGPoint(x: valueTitleX, y: valueTitleY)
        let valueTitleFrame = CGRect(origin: valueTitleOrigin, size: valueTitleSize)
        let valueTitleAttributes = [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueColor]
        let valueDrawTitle = valueTitle as NSString
        valueDrawTitle.draw(in: valueTitleFrame, withAttributes: valueTitleAttributes)
        
        // Unit Label
        let unitFont: UIFont = .systemFont(ofSize: unitFontSize)
        let unitTitleSize = unit.sizeOf(unitFont)
        let unitTitleY = center.y
        let unitTitleX = center.x - unitTitleSize.width / 2
        let unitTitleOrigin = CGPoint(x: unitTitleX, y: unitTitleY)
        let unitTitleFrame = CGRect(origin: unitTitleOrigin, size: unitTitleSize)
        let unitTitleAttributes = [NSAttributedString.Key.font: unitFont, NSAttributedString.Key.foregroundColor: unitColor]
        let unitDrawTitle = unit as NSString
        unitDrawTitle.draw(in: unitTitleFrame, withAttributes: unitTitleAttributes)
        
        // Name Label
        let center2CircleBottom = cos(bottomAngle / 2) * outerRadius
        let nameSpacing = rect.height - center.y - center2CircleBottom
        let nameFont: UIFont = .systemFont(ofSize: nameFontSize)
        let nameTitleSize = name.sizeOf(nameFont)
        let nameTitleY = rect.height - nameTitleSize.height - (nameSpacing - nameTitleSize.height) / 2
        let nameTitleX = center.x - nameTitleSize.width / 2
        let nameTitleOrigin = CGPoint(x: nameTitleX, y: nameTitleY)
        let nameTitleFrame = CGRect(origin: nameTitleOrigin, size: nameTitleSize)
        let nameTitleAttributes = [NSAttributedString.Key.font: nameFont, NSAttributedString.Key.foregroundColor: nameColor]
        let nameDrawTitle = name as NSString
        nameDrawTitle.draw(in: nameTitleFrame, withAttributes: nameTitleAttributes)
    }
}
