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
    private enum Direction {
        case none
        case backward
        case forward
    }
    
    @IBInspectable var maxValue: Double = 0
    @IBInspectable var fillColor: UIColor = .white
    @IBInspectable var shadowColour: UIColor = .black
    @IBInspectable var shadowSize: CGFloat = 5
    @IBInspectable var resultSize: CGFloat = 50
    @IBInspectable var resultLineWidth: CGFloat = 5
    @IBInspectable var resultColor: UIColor = .black
    
    @IBInspectable var valueFontSize: CGFloat = 30
    @IBInspectable var valueColor: UIColor = .black
    @IBInspectable var valueRounded: Bool = false
    @IBInspectable private(set) var currentValue: Double = 0
    
    @IBInspectable var lowerCircleWidth: CGFloat = 8
    @IBInspectable var lowerColor: UIColor = .gray
    
    @IBInspectable var upperCircleWidth: CGFloat = 10
    @IBInspectable var upperColor: UIColor = .green
    
    @IBInspectable var indicatorRadius: CGFloat = 8
    @IBInspectable var indicatorColor: UIColor = .black
    
    var isFailed = false {
        didSet {
            self.oldValue = 0
            currentValue = 0
            setNeedsDisplay()
        }
    }
    
    private var radius: CGFloat = 0
    private var oldValue: Double = 0
    private var currentPoint: CGPoint = .zero
    private var direction: Direction = .none
    
    private var circleLayer = CAShapeLayer()
    private var indicatorLayer = CAShapeLayer()
    
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
        setupInitialState()
    }
    
    func updateValue(_ newValue: Double) {
        let strokeEnd = circleLayer.presentation()?.strokeEnd ?? 1
        switch direction {
        case .none:
            animateCircle(fromValue: currentValue, toValue: newValue)
            animateIndicator(fromValue: radians(from: currentValue), toValue: radians(from: newValue))
            oldValue = currentValue
        case .backward:
            let presentationValue = Double(strokeEnd) * oldValue
            let endRadians = radians(from: presentationValue, offset: startRadians)
            let upperPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
            circleLayer.path = upperPath.cgPath
            animateCircle(fromValue: presentationValue, toValue: newValue)
            animateIndicator(fromValue: radians(from: presentationValue), toValue: radians(from: newValue))
            oldValue = presentationValue
        case .forward:
            let presentationValue = Double(strokeEnd) * currentValue
            let endRadians = radians(from: presentationValue, offset: startRadians)
            let upperPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
            circleLayer.path = upperPath.cgPath
            animateCircle(fromValue: presentationValue, toValue: newValue)
            animateIndicator(fromValue: radians(from: presentationValue), toValue: radians(from: newValue))
            oldValue = presentationValue
        }
        currentValue = newValue
    }
    
    override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print(keyPath ?? "nil")
        if keyPath == "currentValue" {
            dump(change)
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: "currentValue")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setShadow(offset: .zero, blur: shadowSize, color: shadowColour.cgColor)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        
        // Fill
        let fillPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        fillColor.setFill()
        fillPath.fill()
        
        // Lower line
        let lowerPath = fillPath.copy() as! UIBezierPath
        lowerColor.setStroke()
        lowerPath.lineWidth = lowerCircleWidth
        lowerPath.stroke()
        
        // Result
        if isFailed {
            let failPath = getFailPath(center: center, size: resultSize)
            rotate(path: failPath, degree: 45)
            failPath.lineWidth = resultLineWidth
            resultColor.setStroke()
            failPath.stroke()
        } else if currentValue < maxValue {
            let valueFont: UIFont = .systemFont(ofSize: valueFontSize)
            let valueTitle = valueRounded ? "\(Int(currentValue))" : "\(currentValue)"
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
        oldValue = currentValue
    }
    
    private func animateCircle(fromValue: Double, toValue: Double) {
        guard fromValue != toValue else { return }
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        if toValue >= fromValue && toValue != 0 {
            animation.fillMode = .forwards
            animation.fromValue = CGFloat(fromValue / toValue)
            animation.toValue = 1
            direction = .forward
            let endRadians = radians(from: toValue, offset: startRadians)
            let upperPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
            circleLayer.path = upperPath.cgPath
        } else if toValue < fromValue && fromValue != 0 {
            animation.fillMode = .backwards
            animation.fromValue = 1
            animation.toValue = CGFloat(toValue / fromValue)
            direction = .backward
        }
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.delegate = self
        circleLayer.add(animation, forKey: "strokeEnd")
    }
    
    private func animateIndicator(fromValue: CGFloat, toValue: CGFloat) {
        guard fromValue != toValue else { return }
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        if toValue > fromValue {
            let radians = toValue - fromValue + fromValue
            indicatorLayer.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
            animation.fillMode = .forwards
        } else {
            let radians = fromValue - (fromValue - toValue)
            indicatorLayer.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
            animation.fillMode = .backwards
        }
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.isRemovedOnCompletion = true
        indicatorLayer.add(animation, forKey: "transform.rotation.z")
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
    
    private func setupInitialState() {
        clearsContextBeforeDrawing = false
        isOpaque = true
        backgroundColor = .clear
        
        let size = min(bounds.width, bounds.height)
        let offset = max(indicatorRadius * 2, upperCircleWidth, lowerCircleWidth) / 2
        radius = size / 2 - shadowSize - offset
        
        circleLayer.strokeColor = upperColor.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = upperCircleWidth
        circleLayer.lineCap = .round
        layer.addSublayer(circleLayer)
        addObserver(self, forKeyPath: "currentValue", options: [], context: nil)
        
        let circlePoint = CGPoint(x: 0, y: -radius)
        let circlePath = UIBezierPath(arcCenter: circlePoint, radius: indicatorRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        indicatorLayer.path = circlePath.cgPath
        indicatorLayer.fillColor = indicatorColor.cgColor
        indicatorLayer.position = center
        layer.addSublayer(indicatorLayer)
    }
    
    // MARK: Helper
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
    
    func radians(from value: Double, offset: CGFloat = 0) -> CGFloat {
        if maxValue == 0 {
            return 0
        }
        return offset + CGFloat(value / maxValue * (2 * Double.pi))
    }
}

extension CircleProgressView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            let endRadians = radians(from: currentValue, offset: startRadians)
            let upperPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
            circleLayer.path = upperPath.cgPath
            direction = .none
        }
    }
}
