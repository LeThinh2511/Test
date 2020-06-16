//
//  OBDMeterView.swift
//  Test
//
//  Created by Techchain on 5/29/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import Foundation
import UIKit

protocol OBDMeterViewDelegate: class {
    func meterView(_ view: OBDMeterView, changedValue value: Double)
}

class OBDMeterView: UIView {
    private enum Direction {
        case none
        case backward
        case forward
    }
    
    @IBInspectable var maxValue: Double = 360
    @IBInspectable private(set) var currentValue: Double = 180
    
    @IBInspectable var name: String = "Azimuth"
    @IBInspectable var nameFontSize: CGFloat = 17
    @IBInspectable var nameColor: UIColor = .red
    
    @IBInspectable var valueFontSize: CGFloat = 30
    @IBInspectable var valueColor: UIColor = .white
    @IBInspectable var valueRounded: Bool = false
    
    @IBInspectable var unit: String = ""
    @IBInspectable var unitFontSize: CGFloat = 14
    @IBInspectable var unitColor: UIColor = .white
    
    @IBInspectable var lowerLineWidth: CGFloat = 8
    @IBInspectable var lowerColor: UIColor = .gray
    
    @IBInspectable var upperLineWidth: CGFloat = 10
    @IBInspectable var upperColor: UIColor = .green
    
    @IBInspectable var colorShadow: UIColor = .black
    @IBInspectable var radiusShadow: CGFloat = 0
    @IBInspectable var offsetShadow: CGSize = .zero
    
    private var valueLabel: UILabel!
    private var radius: CGFloat = 0
    private var oldValue: Double = 0
    private var direction: Direction = .none
    private var firstLoad = true
    
    private var upperCircleLayer = CAShapeLayer()
    
    private var timer: Timer?
    private let bottomRadians: CGFloat = 0.5 * .pi
    private let startRadians: CGFloat = 0.75 * .pi
    private var endRadians: CGFloat = 0.25 * .pi
    private var centerPoint: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    var animationDuration: Double = 1
    var animationStyle: CAMediaTimingFunctionName = .linear
    
    weak var delegate: OBDMeterViewDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if firstLoad {
            setupInitialState()
            firstLoad = false
        }
    }
    
    func updateValue(_ newValue: Double) {
        guard newValue >= 0 else { return }
        let strokeEnd = upperCircleLayer.presentation()?.strokeEnd ?? 1
        switch direction {
        case .none:
            animateUpperCircle(fromValue: currentValue, toValue: newValue)
            oldValue = currentValue
        case .backward, .forward:
            let currentMaxValue = direction == .backward ? oldValue : currentValue
            let presentationValue = Double(strokeEnd) * currentMaxValue
            let endRadians = radians(from: presentationValue, offset: startRadians)
            let upperPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
            upperCircleLayer.path = upperPath.cgPath
            animateUpperCircle(fromValue: presentationValue, toValue: newValue)
            oldValue = presentationValue
        }
        resumeReporter()
        currentValue = newValue
    }
    
    override func draw(_ rect: CGRect) {
        // Lower Line
        let lowerLinePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        lowerLinePath.lineCapStyle = .round
        lowerLinePath.lineWidth = lowerLineWidth
        lowerColor.setStroke()
        lowerLinePath.stroke()

        // Name Label
        let offset = max(upperLineWidth, lowerLineWidth) / 2
        let outerRadius = radius + offset
        let center2CircleBottom = cos(bottomRadians / 2) * outerRadius
        let nameSpacing = rect.height - centerPoint.y - center2CircleBottom
        let nameFont: UIFont = .systemFont(ofSize: nameFontSize)
        let nameTitleSize = name.sizeOf(nameFont)
        let nameTitleY = rect.height - nameTitleSize.height - (nameSpacing - nameTitleSize.height) / 2
        let nameTitleX = centerPoint.x - nameTitleSize.width / 2
        let nameTitleOrigin = CGPoint(x: nameTitleX, y: nameTitleY)
        let nameTitleFrame = CGRect(origin: nameTitleOrigin, size: nameTitleSize)
        let nameTitleAttributes = [NSAttributedString.Key.font: nameFont, NSAttributedString.Key.foregroundColor: nameColor]
        let nameDrawTitle = name as NSString
        nameDrawTitle.draw(in: nameTitleFrame, withAttributes: nameTitleAttributes)
    }
    
    // Animating upper circle from an value to another value
    private func animateUpperCircle(fromValue: Double, toValue: Double) {
        guard fromValue != toValue else { return }
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        if toValue >= fromValue && toValue != 0 {
            animation.fillMode = .forwards
            animation.fromValue = CGFloat(fromValue / toValue)
            animation.toValue = 1
            direction = .forward
            let endRadians = radians(from: toValue, offset: startRadians)
            let upperPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
            upperCircleLayer.path = upperPath.cgPath
        } else if toValue < fromValue && fromValue != 0 {
            animation.fillMode = .backwards
            animation.fromValue = 1
            animation.toValue = CGFloat(toValue / fromValue)
            direction = .backward
        }
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: animationStyle)
        animation.delegate = self
        upperCircleLayer.add(animation, forKey: "strokeEnd")
    }
    
    private func setupInitialState() {
        clearsContextBeforeDrawing = false
        isOpaque = true
        backgroundColor = .clear
        let size = min(bounds.width, bounds.height)
        let offset = max(upperLineWidth, lowerLineWidth) / 2
        radius = size / 2 - radiusShadow - offset
        
        let endRadians = radians(from: currentValue)
        let upperPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        upperCircleLayer.path = upperPath.cgPath
        upperCircleLayer.strokeColor = upperColor.cgColor
        upperCircleLayer.fillColor = UIColor.clear.cgColor
        upperCircleLayer.lineWidth = upperLineWidth
        upperCircleLayer.lineCap = .round
        upperCircleLayer.shadowColor = colorShadow.cgColor
        upperCircleLayer.shadowOffset = offsetShadow
        upperCircleLayer.shadowRadius = radiusShadow
        upperCircleLayer.shadowOpacity = 1
        layer.addSublayer(upperCircleLayer)
        
        valueLabel = UILabel()
        valueLabel.text = "\(Int(currentValue))"
        valueLabel.textAlignment = .center
        valueLabel.font = .systemFont(ofSize: valueFontSize)
        valueLabel.textColor = valueColor
        let roundedValue = Double(round(10 * currentValue) / 10)
        if valueRounded {
            valueLabel.text = "\(Int(roundedValue))"
        } else {
            valueLabel.text = "\(roundedValue)"
        }
        
        let unitLabel = UILabel()
        unitLabel.text = unit
        unitLabel.textAlignment = .center
        unitLabel.font = .systemFont(ofSize: unitFontSize)
        unitLabel.textColor = unitColor
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(unitLabel)
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    // MARK: Helper
    private func radians(from value: Double, offset: CGFloat = 0) -> CGFloat {
        if maxValue == 0 {
            return 0
        }
        return startRadians + CGFloat(value / maxValue) * (2 * .pi - bottomRadians)
    }
    
    private func changeValue(newValue: Double) {
        delegate?.meterView(self, changedValue: newValue)
        let roundedValue = Double(round(10 * newValue) / 10)
        if valueRounded {
            valueLabel.text = "\(Int(roundedValue))"
        } else {
            valueLabel.text = "\(roundedValue)"
        }
    }
    
    private func resumeReporter() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [weak self] timer in
            guard let `self` = self, let strokeEnd = self.upperCircleLayer.presentation()?.strokeEnd else {
                return
            }
            switch self.direction {
            case .backward:
                let value = Double(strokeEnd) * self.oldValue
                self.changeValue(newValue: value)
            case .forward:
                let value = Double(strokeEnd) * self.currentValue
                self.changeValue(newValue: value)
            case .none: break
            }
        })
    }
}

extension OBDMeterView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            let endRadians = radians(from: currentValue, offset: startRadians)
            let upperPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
            upperCircleLayer.path = upperPath.cgPath
            direction = .none
            changeValue(newValue: currentValue)
            timer?.invalidate()
        }
    }
}
