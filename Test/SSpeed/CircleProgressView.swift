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
    
    private var radius: CGFloat = 0
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
            animateIndicator(fromRadians: radians(from: currentValue), toRadians: radians(from: newValue))
        case .backward, .forward:
            let currentValue = Double(strokeEnd) * maxValue
            animateCircle(fromValue: currentValue, toValue: newValue)
            animateIndicator(fromRadians: radians(from: currentValue), toRadians: radians(from: newValue))
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
        guard fromValue != toValue, maxValue > 0 else { return }
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = CGFloat(fromValue / maxValue)
        animation.toValue = CGFloat(toValue / maxValue)
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: animationStyle)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        direction = toValue >= fromValue ? .forward : .backward
        circleLayer.add(animation, forKey: "strokeEnd")
    }
    
    // Animating indicator from an angle to another angle
    private func animateIndicator(fromRadians: CGFloat, toRadians: CGFloat) {
        guard fromRadians != toRadians else { return }
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = fromRadians
        animation.toValue = toRadians
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: animationStyle)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        indicatorLayer.add(animation, forKey: "transform.rotation.z")
    }
    
    private func setupInitialState() {
        clearsContextBeforeDrawing = false
        isOpaque = true
        backgroundColor = .clear
        
        let size = min(bounds.width, bounds.height)
        let offset = max(radiusIndicator * 2, upperCircleWidth, lowerCircleWidth) / 2
        radius = size / 2 - radiusShadow - offset

        let upperPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        circleLayer.path = upperPath.cgPath
        circleLayer.strokeColor = upperColor.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = upperCircleWidth
        circleLayer.lineCap = .round
        circleLayer.strokeEnd = 0
        layer.addSublayer(circleLayer)
        
        let indicatorPoint = CGPoint(x: 0, y: -radius)
        let indicatorPath = UIBezierPath(arcCenter: indicatorPoint, radius: radiusIndicator, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        indicatorLayer.path = indicatorPath.cgPath
        indicatorLayer.fillColor = colorIndicator.cgColor
        indicatorLayer.position = centerPoint
        layer.addSublayer(indicatorLayer)
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
            case .backward, .forward:
                let value = Double(strokeEnd) * self.maxValue
                self.delegate?.circleProgressView(view: self, didUpdate: value)
            case .none: break
            }
        })
    }
}

extension CircleProgressView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            direction = .none
            delegate?.circleProgressView(view: self, didUpdate: currentValue)
            timer?.invalidate()
        }
    }
}
