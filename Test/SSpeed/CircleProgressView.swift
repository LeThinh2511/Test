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
    @IBInspectable var maxValue: Double = 0
    @IBInspectable var fillColor: UIColor = .red
    @IBInspectable var shadowColour: UIColor = .black
    @IBInspectable var shadowSize: CGFloat = 5
    @IBInspectable var resultSize: CGFloat = 50
    @IBInspectable var resultLineWidth: CGFloat = 5
    @IBInspectable var resultColor: UIColor = .black
    
    @IBInspectable var valueFontSize: CGFloat = 30
    @IBInspectable var valueColor: UIColor = .black
    @IBInspectable var valueRounded: Bool = true
    @IBInspectable var value: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var lowerLineWidth: CGFloat = 8
    @IBInspectable var lowerColor: UIColor = .gray
    
    @IBInspectable var upperLineWidth: CGFloat = 10
    @IBInspectable var upperColor: UIColor = .green
    
    @IBInspectable var circleRadius: CGFloat = 8
    @IBInspectable var circleColor: UIColor = .black
    
    var isFailed = false {
        didSet {
            self.oldValue = 0
            value = 0
            setNeedsDisplay()
        }
    }
    
    private var radius: CGFloat = 0
    private var oldValue: Double = 0
    private var currentPoint: CGPoint = .zero
    
    private var lineLayer = CAShapeLayer()
    private var circleLayer = CAShapeLayer()
    
    private let startRadians = CGFloat(-0.5 * Double.pi)
    private var endRadians: CGFloat {
        return CGFloat(2 * Double.pi) + startRadians
    }
    
    private let animationDuration: Double = 1
    
    override class var layerClass: AnyClass {
        return CALayer.self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clearsContextBeforeDrawing = false
        isOpaque = true
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let size = min(rect.width, rect.height)
//        let x = (rect.width - size) / 2
//        let y = (rect.height - size) / 2
//        let frame = CGRect(x: x, y: y, width: size, height: size)
        
        let offset = max(circleRadius * 2, upperLineWidth, lowerLineWidth) / 2
        radius = size / 2 - shadowSize - offset
//        let outerRadius = radius + offset / 2
//        let innerRadius = radius - offset / 2
        
        context.setShadow(offset: .zero, blur: shadowSize, color: shadowColour.cgColor)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        
        // Fill
        let fillPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        fillColor.setFill()
        fillPath.fill()
        
        // Lower line
        let lowerPath = fillPath.copy() as! UIBezierPath
        lowerColor.setStroke()
        lowerPath.lineWidth = lowerLineWidth
        lowerPath.stroke()
        
        // Upper line
        animateLine()
        
        // Circle
        animateCircle()
        
        // Result
        if isFailed {
            let failPath = getFailPath(center: center, size: resultSize)
            rotate(path: failPath, degree: 45)
            failPath.lineWidth = resultLineWidth
            resultColor.setStroke()
            failPath.stroke()
        } else if value < maxValue {
            let valueFont: UIFont = .systemFont(ofSize: valueFontSize)
            let valueTitle = valueRounded ? "\(Int(value))" : "\(value)"
            let valueTitleSize = valueTitle.sizeOf(valueFont)
            let valueTitleY = center.y - valueTitleSize.height / 2
            let valueTitleX = center.x - valueTitleSize.width / 2
            let valueTitleOrigin = CGPoint(x: valueTitleX, y: valueTitleY)
            let valueTitleFrame = CGRect(origin: valueTitleOrigin, size: valueTitleSize)
            let valueTitleAttributes = [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueColor]
            let valueDrawTitle = valueTitle as NSString
            valueDrawTitle.draw(in: valueTitleFrame, withAttributes: valueTitleAttributes)
        } else {
            let successPath = getSuccessPath(center: center, size: resultSize)
            var transform: CGAffineTransform = .identity
            transform = transform.translatedBy(x: resultSize / 4, y: resultSize / 4)
            successPath.apply(transform)
            rotate(path: successPath, degree: 45)
            successPath.lineWidth = resultLineWidth
            resultColor.setStroke()
            successPath.stroke()
        }
        
        context.endTransparencyLayer()
        oldValue = value
    }
    
    private var oldRadians: CGFloat {
        if maxValue <= 0 { return 0 }
        return startRadians + CGFloat(oldValue / maxValue * (2 * Double.pi))
    }
    
    private var currentRadians: CGFloat {
        if maxValue <= 0 { return 0 }
        return startRadians + CGFloat(value / maxValue * (2 * Double.pi))
    }
    
    private var lineFromValue: CGFloat {
        if value <= 0 { return 0 }
        return CGFloat(oldValue / value)
    }
    
    private var circleFromValue: CGFloat {
        return oldRadians - currentRadians
    }
    
    private func animateLine() {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = lineFromValue
        animation.toValue = 1
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fillMode = .forwards
        animation.delegate = self
        let upperPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startRadians, endAngle: currentRadians, clockwise: true)
        currentPoint = upperPath.currentPoint
        lineLayer.path = upperPath.cgPath
        lineLayer.strokeColor = upperColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = upperLineWidth
        lineLayer.lineCap = .round
        layer.addSublayer(lineLayer)
        lineLayer.add(animation, forKey: "line")
    }
    
    private func animateCircle() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = circleFromValue
        animation.toValue = 0
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = animationDuration
        animation.isAdditive = false
        animation.delegate = self
        let circlePoint = CGPoint(x: currentPoint.x - center.x, y: currentPoint.y - center.y)
        let circlePath = UIBezierPath(arcCenter: circlePoint, radius: circleRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = circleColor.cgColor
        circleLayer.position = center
        layer.addSublayer(circleLayer)
        circleLayer.add(animation, forKey: nil)
    }
    
    // "X" Path
    private func getFailPath(center: CGPoint, size: CGFloat) -> UIBezierPath {
        let failPath = UIBezierPath()
        
        let startXPoint = CGPoint(x: center.x - size / 2, y: center.y)
        let endXPoint = CGPoint(x: center.x + size / 2, y: center.y)
        let startYPoint = CGPoint(x: center.x, y: center.y - size / 2)
        let endYPoint = CGPoint(x: center.x, y: center.y + size / 2)
        
        failPath.move(to: startXPoint)
        failPath.addLine(to: endXPoint)
        failPath.move(to: startYPoint)
        failPath.addLine(to: endYPoint)
        
        return failPath
    }
    
    // "V" Path
    private func getSuccessPath(center: CGPoint, size: CGFloat) -> UIBezierPath {
        let successPath = UIBezierPath()
        
        let offset = resultLineWidth / 2
        let startXPoint = CGPoint(x: center.x - size / 2 + offset, y: center.y)
        let endXPoint = CGPoint(x: center.x + offset, y: center.y)
        let startYPoint = CGPoint(x: center.x, y: center.y + offset)
        let endYPoint = CGPoint(x: center.x, y: center.y - size + offset)
        
        successPath.move(to: startXPoint)
        successPath.addLine(to: endXPoint)
        successPath.move(to: startYPoint)
        successPath.addLine(to: endYPoint)
        
        return successPath
    }
    
    private func rotate(path: UIBezierPath, degree: CGFloat) {
        let bounds: CGRect = path.cgPath.boundingBox
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let radians = degree / 180.0 * .pi
        var transform: CGAffineTransform = .identity
        transform = transform.translatedBy(x: center.x, y: center.y)
        transform = transform.rotated(by: radians)
        transform = transform.translatedBy(x: -center.x, y: -center.y)
        path.apply(transform)
    }
}

extension CircleProgressView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    }
}
