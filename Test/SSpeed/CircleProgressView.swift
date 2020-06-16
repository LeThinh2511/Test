//
//  CircleProgressView.swift
//  Test
//
//  Created by Techchain on 6/3/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

protocol CircleProgressViewDelegate: class {
    func circleProgressView(view: CircleProgressView, didUpdate value: Double)
}

@IBDesignable
class CircleProgressView: UIView {
    private enum Direction {
        case none
        case backward
        case forward
    }
    
    @IBInspectable var maxValue: Double = 0
    @IBInspectable var fillColor: UIColor = .white
    @IBInspectable private(set) var currentValue: Double = 0
    
    @IBInspectable var colorShadow: UIColor = .black
    @IBInspectable var radiusShadow: CGFloat = 0
    @IBInspectable var offsetShadow: CGSize = .zero
    
    @IBInspectable var lowerCircleWidth: CGFloat = 8
    @IBInspectable var lowerColor: UIColor = .gray
    
    @IBInspectable var upperCircleWidth: CGFloat = 10
    @IBInspectable var upperColor: UIColor = .green
    
    @IBInspectable var radiusIndicator: CGFloat = 8
    @IBInspectable var colorIndicator: UIColor = .black
    
    var isFailed = false {
        didSet {
            self.oldValue = 0
            currentValue = 0
            circleLayer.removeAllAnimations()
            indicatorLayer.removeAllAnimations()
            let endRadians = radians(from: currentValue, offset: startRadians)
            let upperPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
            circleLayer.path = upperPath.cgPath
            indicatorLayer.transform = CATransform3DMakeRotation(0, 0.0, 0.0, 1.0)
        }
    }
    
    private var radius: CGFloat = 0
    private var oldValue: Double = 0
    private var direction: Direction = .none
    private var centerPoint: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private var circleLayer = CAShapeLayer()
    private var indicatorLayer = CAShapeLayer()
    
    private let startRadians = CGFloat(-0.5 * Double.pi)
    private var endRadians: CGFloat {
        return CGFloat(2 * Double.pi) + startRadians
    }
    
    var animationDuration: Double = 1
    var animationStyle: CAMediaTimingFunctionName = .linear
    private var timer: Timer?
    private var firstLoad = true
    
    weak var delegate: CircleProgressViewDelegate?
    
    override class var layerClass: AnyClass {
        return CALayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if firstLoad {
            setupInitialState()
            firstLoad = false
        }
    }
    
    func updateValue(_ newValue: Double) {
        guard newValue >= 0 else { return }
        let strokeEnd = circleLayer.presentation()?.strokeEnd ?? 1
        switch direction {
        case .none:
            animateCircle(fromValue: currentValue, toValue: newValue)
            animateIndicator(fromValue: radians(from: currentValue), toValue: radians(from: newValue))
            oldValue = currentValue
        case .backward, .forward:
            let currentMaxValue = direction == .backward ? oldValue : currentValue
            let presentationValue = Double(strokeEnd) * currentMaxValue
            let endRadians = radians(from: presentationValue, offset: startRadians)
            let upperPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
            circleLayer.path = upperPath.cgPath
            animateCircle(fromValue: presentationValue, toValue: newValue)
            animateIndicator(fromValue: radians(from: presentationValue), toValue: radians(from: newValue))
            oldValue = presentationValue
        }
        resumeReporter()
        currentValue = newValue
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setShadow(offset: offsetShadow, blur: radiusShadow, color: colorShadow.cgColor)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        
        // Fill
        let fillPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        fillColor.setFill()
        fillPath.fill()
        
        // Lower line
        let lowerPath = fillPath.copy() as! UIBezierPath
        lowerColor.setStroke()
        lowerPath.lineWidth = lowerCircleWidth
        lowerPath.stroke()
        
        context.endTransparencyLayer()
    }
    
    // Animating upper circle from an value to another value
    private func animateCircle(fromValue: Double, toValue: Double) {
        guard fromValue != toValue else { return }
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        if toValue >= fromValue && toValue != 0 {
            animation.fillMode = .forwards
            animation.fromValue = CGFloat(fromValue / toValue)
            animation.toValue = 1
            direction = .forward
            let endRadians = radians(from: toValue, offset: startRadians)
            let upperPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
            circleLayer.path = upperPath.cgPath
        } else if toValue < fromValue && fromValue != 0 {
            animation.fillMode = .backwards
            animation.fromValue = 1
            animation.toValue = CGFloat(toValue / fromValue)
            direction = .backward
        }
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: animationStyle)
        animation.delegate = self
        circleLayer.add(animation, forKey: "strokeEnd")
    }
    
    // Animating indicator from an angle to another angle
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
        animation.timingFunction = CAMediaTimingFunction(name: animationStyle)
        animation.isRemovedOnCompletion = true
        indicatorLayer.add(animation, forKey: "transform.rotation.z")
    }
    
    private func setupInitialState() {
        clearsContextBeforeDrawing = false
        isOpaque = true
        backgroundColor = .clear
        
        let size = min(bounds.width, bounds.height)
        let offset = max(radiusIndicator * 2, upperCircleWidth, lowerCircleWidth) / 2
        radius = size / 2 - radiusShadow - offset
        
        circleLayer.strokeColor = upperColor.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = upperCircleWidth
        circleLayer.lineCap = .round
        layer.addSublayer(circleLayer)
        
        let indicatorPoint = CGPoint(x: 0, y: -radius)
        let indicatorPath = UIBezierPath(arcCenter: indicatorPoint, radius: radiusIndicator, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        indicatorLayer.path = indicatorPath.cgPath
        indicatorLayer.fillColor = colorIndicator.cgColor
        indicatorLayer.position = centerPoint
        layer.addSublayer(indicatorLayer)
    }
    
    private func updateShadow() {
        let shadowPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        let indicatorPoint = CGPoint(x: 0, y: -radius)
        let indicatorPath = UIBezierPath(arcCenter: indicatorPoint, radius: radiusIndicator, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        let endRadians = radians(from: currentValue, offset: startRadians)
        let upperCirclePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        shadowPath.append(upperCirclePath)
        shadowPath.append(indicatorPath)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowRadius = radiusShadow
        layer.shadowOffset = offsetShadow
        layer.shadowOpacity = 1
        layer.shadowColor = colorShadow.cgColor
    }
    
    // MARK: Helper
    private func radians(from value: Double, offset: CGFloat = 0) -> CGFloat {
        if maxValue == 0 {
            return 0
        }
        return offset + CGFloat(value / maxValue * (2 * Double.pi))
    }
    
    private func resumeReporter() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [weak self] timer in
            guard let `self` = self, let strokeEnd = self.circleLayer.presentation()?.strokeEnd else {
                return
            }
            switch self.direction {
            case .backward:
                let value = Double(strokeEnd) * self.oldValue
                self.delegate?.circleProgressView(view: self, didUpdate: value)
            case .forward:
                let value = Double(strokeEnd) * self.currentValue
                self.delegate?.circleProgressView(view: self, didUpdate: value)
            case .none: break
            }
        })
    }
}

extension CircleProgressView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            let endRadians = radians(from: currentValue, offset: startRadians)
            let upperPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
            circleLayer.path = upperPath.cgPath
            direction = .none
            delegate?.circleProgressView(view: self, didUpdate: currentValue)
            timer?.invalidate()
        }
    }
}
