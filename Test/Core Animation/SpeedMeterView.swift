//
//  SpeedMeterView.swift
//  Test
//
//  Created by Techchain on 6/16/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

protocol SpeedMeterViewDelegate: class {
    func speedMeterView(_ view: SpeedMeterView, didChange value: CGFloat)
}

class SpeedMeterView: UIView {
    private enum Direction {
        case none
        case backward
        case forward
    }
    
    @IBInspectable var maxValue: CGFloat = 180
    @IBInspectable private(set) var currentValue: CGFloat = 0
    
    @IBInspectable var smallStepValue: CGFloat = 5
    @IBInspectable var heightSmallSeparator: CGFloat = 8
    @IBInspectable var widthSmallSeparator: CGFloat = 4
    @IBInspectable var colorSmallSeparator: UIColor = .white
    
    @IBInspectable var bigStepValue: CGFloat = 20
    @IBInspectable var heightBigSeparator: CGFloat = 17
    @IBInspectable var widthBigSeparator: CGFloat = 4
    @IBInspectable var colorBigSeparator: UIColor = .red
    
    @IBInspectable var valueFontSize: CGFloat = 14
    @IBInspectable var valueColor: UIColor = .white
    
    @IBInspectable var indicatorHeight: CGFloat = 70
    @IBInspectable var indicatorWidth: CGFloat = 30
    @IBInspectable var indicatorRate: CGFloat = 0.3
    @IBInspectable var indicatorColor: UIColor = .white
    
    @IBInspectable var centerRadius: CGFloat = 6
    @IBInspectable var centerColor: UIColor = .gray
    
    private var direction: Direction = .none
    private var firstLoad = true
    
    private var indicatorLayer = CAShapeLayer()
    private var currentValueLabel = UILabel()
    
    private var valueRectSize = CGSize(width: 50, height: 30)
    private var valueRectOffset: CGFloat = 40
    
    private var timer: Timer?
    private let bottomRadians: CGFloat = 0.5 * .pi
    private let startRadians: CGFloat = 0.75 * .pi
    private var endRadians: CGFloat = 2.25 * .pi
    private var centerPoint: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    private var radius: CGFloat {
        let size = min(bounds.width, bounds.height)
        return size / 2
    }
    
    weak var delegate: SpeedMeterViewDelegate?
    var animationDuration: Double = 1
    var animationStyle: CAMediaTimingFunctionName = .linear
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if firstLoad {
            setupInitialState()
            firstLoad = false
        }
    }
    
    var valuePerRadians: CGFloat {
        return maxValue / (2 * .pi - bottomRadians)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
//        context.setShouldAntialias(true)
        drawBigSeparator(in: context)
        drawSmallSeparator(in: context)
        let currentValueOrigin = CGPoint(x: centerPoint.x - valueRectSize.width / 2, y: centerPoint.y + valueRectOffset)
        let currentValueRect = CGRect(origin: currentValueOrigin, size: valueRectSize)
        let currentValuePath = UIBezierPath(rect: currentValueRect)
        valueColor.setStroke()
        currentValuePath.lineWidth = 1
        currentValuePath.stroke()
    }
    
    func updateValue(_ newValue: CGFloat) {
        guard newValue >= 0 else { return }
        switch direction {
        case .none:
            animateIndicator(fromRadians: radians(from: currentValue), toRadians: radians(from: newValue))
        case .backward, .forward:
            let rotatedValue = indicatorLayer.presentation()?.value(forKeyPath: "transform.rotation.z") as? CGFloat ?? 0
            animateIndicator(fromRadians: rotatedValue, toRadians: radians(from: newValue))
        }
        resumeReporter()
        currentValue = newValue
    }
    
    // Animating indicator from an angle to another angle
    private func animateIndicator(fromRadians: CGFloat, toRadians: CGFloat) {
        guard fromRadians != toRadians else { return }
        direction = toRadians > fromRadians ? .forward : .backward
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = fromRadians
        animation.toValue = toRadians
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: animationStyle)
        animation.fillMode = .forwards
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        indicatorLayer.add(animation, forKey: "transform.rotation.z")
    }
    
    private func setupInitialState() {
        clearsContextBeforeDrawing = false
        isOpaque = true
        backgroundColor = .clear
        
        // Indicator
        let indicatorPath = UIBezierPath()
        let firstPoint = CGPoint(x: -indicatorWidth / 2, y: 0)
        let secondPoint = CGPoint(x: 0, y: (-indicatorHeight * (1 - indicatorRate)))
        let thirdPoint = CGPoint(x: indicatorWidth / 2, y: 0)
        let fourthPoint = CGPoint(x: 0, y: indicatorHeight * indicatorRate)
        indicatorPath.move(to: firstPoint)
        indicatorPath.addLine(to: secondPoint)
        indicatorPath.addLine(to: thirdPoint)
        indicatorPath.addLine(to: fourthPoint)
        indicatorPath.close()
        indicatorLayer.fillColor = indicatorColor.cgColor
        indicatorLayer.path = indicatorPath.cgPath
        layer.addSublayer(indicatorLayer)
        indicatorLayer.position = centerPoint
        indicatorLayer.shadowColor = UIColor.black.cgColor
        indicatorLayer.shadowRadius = 3
        indicatorLayer.shadowOffset = .zero
        indicatorLayer.shadowOpacity = 0.8
        indicatorLayer.transform = CATransform3DMakeRotation(1.5 * .pi - startRadians, 0, 0, -1)
        
        // Center Point
        let centerPath = UIBezierPath(arcCenter: centerPoint, radius: centerRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        let centerLayer = CAShapeLayer()
        centerLayer.path = centerPath.cgPath
        centerLayer.fillColor = centerColor.cgColor
        centerLayer.lineWidth = centerRadius
        layer.addSublayer(centerLayer)
        
        // Current Value Label
        currentValueLabel = UILabel(frame: .zero)
        currentValueLabel.font = .systemFont(ofSize: valueFontSize)
        currentValueLabel.textColor = valueColor
        currentValueLabel.textAlignment = .center
        currentValueLabel.text = "\(Int(currentValue))"
        currentValueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(currentValueLabel)
        NSLayoutConstraint.activate([
            currentValueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            currentValueLabel.heightAnchor.constraint(equalToConstant: valueRectSize.height),
            currentValueLabel.widthAnchor.constraint(equalToConstant: valueRectSize.width),
            currentValueLabel.topAnchor.constraint(equalTo: topAnchor, constant: centerPoint.y + valueRectOffset)
        ])
    }
    
    // MARK: Helper
    private func radiansGap(from value: CGFloat) -> CGFloat {
        if valuePerRadians == 0 {
            return 0
        }
        return value / valuePerRadians
    }
    
    private func radians(from value: CGFloat) -> CGFloat {
        return (startRadians + radiansGap(from: value)) - 1.5 * .pi
    }
    
    private func changeValue(newValue: CGFloat) {
        let roundedValue = Double(round(10 * newValue) / 10)
        currentValueLabel.text = "\(Int(roundedValue))"
        delegate?.speedMeterView(self, didChange: newValue)
    }
    
    private func resumeReporter() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [weak self] timer in
            guard let `self` = self, let rotatedRadians = self.indicatorLayer.presentation()?.value(forKeyPath: "transform.rotation.z") as? CGFloat else {
                return
            }
            switch self.direction {
            case .backward, .forward:
                let value = (rotatedRadians + 1.5 * .pi - self.startRadians) * self.valuePerRadians
                self.changeValue(newValue: value)
            case .none: break
            }
        })
    }
}

extension SpeedMeterView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            direction = .none
            changeValue(newValue: currentValue)
            timer?.invalidate()
        }
    }
}

extension SpeedMeterView {
    func drawBigSeparator(in context: CGContext) {
        var currentRadians = startRadians
        context.saveGState()
        let bigStepRadians = bigStepValue / valuePerRadians
        let bigSeparatorFrame = CGRect(x: -widthBigSeparator / 2, y: -heightBigSeparator / 2, width: widthBigSeparator, height: heightBigSeparator)
        let bigSeparatorPath = UIBezierPath(rect: bigSeparatorFrame)
        colorBigSeparator.setFill()
        context.translateBy(x: bounds.midX, y: bounds.midY)
        var currentValue: CGFloat = 0
        while currentRadians <= endRadians + pow(10, -10) {
            // Separator
            context.saveGState()
            context.rotate(by: -0.5 * .pi)
            context.rotate(by: currentRadians)
            context.translateBy(x: 0, y: radius - heightBigSeparator / 2)
            bigSeparatorPath.fill()
            context.restoreGState()
            
            // Value Label
            context.saveGState()
            let valueLabel = "\(Int(currentValue))"
            let valueFont: UIFont = .systemFont(ofSize: valueFontSize)
            let valueLabelSize = valueLabel.sizeOf(valueFont)
            let valueLabelOrigin = CGPoint(x: -valueLabelSize.width / 2, y: -valueLabelSize.height / 2)
            let valueLabelFrame = CGRect(origin: valueLabelOrigin, size: valueLabelSize)
            context.rotate(by: -0.5 * .pi)
            context.rotate(by: currentRadians)
            context.translateBy(x: 0, y: radius - heightBigSeparator / 2 - valueLabelSize.height)
            context.rotate(by: .pi)
            let valueAttributes = [NSAttributedString.Key.font: valueFont, NSAttributedString.Key.foregroundColor: valueColor]
            (valueLabel as NSString).draw(in: valueLabelFrame, withAttributes: valueAttributes)
            context.restoreGState()
            
            currentValue += bigStepValue
            currentRadians += bigStepRadians
        }
        context.restoreGState()
    }
    
    func drawSmallSeparator(in context: CGContext) {
        var currentRadians = startRadians
        context.saveGState()
        let smallStepRadians = smallStepValue / valuePerRadians
        let smallSeparatorFrame = CGRect(x: -widthSmallSeparator / 2, y: -heightSmallSeparator / 2, width: widthSmallSeparator, height: heightSmallSeparator)
        let smallSeparatorPath = UIBezierPath(rect: smallSeparatorFrame)
        colorSmallSeparator.setFill()
        context.translateBy(x: bounds.midX, y: bounds.midY)
        while currentRadians <= endRadians + pow(10, -10) {
            context.saveGState()
            context.rotate(by: -0.5 * .pi)
            context.rotate(by: currentRadians)
            context.translateBy(x: 0, y: radius - heightSmallSeparator / 2)
            smallSeparatorPath.fill()
            currentRadians += smallStepRadians
            context.restoreGState()
        }
        context.restoreGState()
    }
}
