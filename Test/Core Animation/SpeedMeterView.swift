//
//  SpeedMeterView.swift
//  Test
//
//  Created by Techchain on 6/16/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class SpeedMeterView: UIView {
    private enum Direction {
        case none
        case backward
        case forward
    }
    
    @IBInspectable var maxValue: Double = 180
    @IBInspectable private(set) var currentValue: Double = 180
    
    @IBInspectable var smallStepValue: CGFloat = 5
    @IBInspectable var smallSeparatorHeight: CGFloat = 8
    @IBInspectable var smallSeparatorWidth: CGFloat = 4
    @IBInspectable var smallSeparatorColor: UIColor = .white
    
    @IBInspectable var bigStepValue: CGFloat = 20
    @IBInspectable var bigSeparatorHeight: CGFloat = 17
    @IBInspectable var bigSeparatorWidth: CGFloat = 4
    @IBInspectable var bigSeparatorColor: UIColor = .red
    
    @IBInspectable var stepValueFontSize: CGFloat = 20
    @IBInspectable var stepValueColor: UIColor = .white
    
    @IBInspectable var indicatorHeight: CGFloat = 70
    @IBInspectable var indicatorWidth: CGFloat = 30
    @IBInspectable var indicatorRate: CGFloat = 0.3
    @IBInspectable var indicatorColor: UIColor = .white
    
    @IBInspectable var centerRadius: CGFloat = 6
    @IBInspectable var centerColor: UIColor = .gray
    
    private var direction: Direction = .none
    private var firstLoad = true
    
    private var indicatorLayer = CAShapeLayer()
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupInitialState()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        var currentRadians = startRadians
        let valuePerRadians = CGFloat(maxValue) / (2 * .pi - bottomRadians)
        // Big step
        context.saveGState()
        let bigStepRadians = bigStepValue / valuePerRadians
        let bigSeparatorFrame = CGRect(x: -bigSeparatorWidth / 2, y: -bigSeparatorHeight / 2, width: bigSeparatorWidth, height: bigSeparatorHeight)
        let bigSeparatorPath = UIBezierPath(rect: bigSeparatorFrame)
        bigSeparatorColor.setFill()
        context.translateBy(x: bounds.midX, y: bounds.midY)
        while currentRadians <= endRadians + pow(10, -10) {
            context.saveGState()
            context.rotate(by: -0.5 * .pi)
            context.rotate(by: currentRadians)
            context.translateBy(x: 0, y: radius - bigSeparatorHeight / 2)
            bigSeparatorPath.fill()
            currentRadians += bigStepRadians
            context.restoreGState()
        }
        context.restoreGState()
        
        // Small step
        currentRadians = startRadians
        context.saveGState()
        let smallStepRadians = smallStepValue / valuePerRadians
        let smallSeparatorFrame = CGRect(x: -smallSeparatorWidth / 2, y: -smallSeparatorHeight / 2, width: smallSeparatorWidth, height: smallSeparatorHeight)
        let smallSeparatorPath = UIBezierPath(rect: smallSeparatorFrame)
        smallSeparatorColor.setFill()
        context.translateBy(x: bounds.midX, y: bounds.midY)
        while currentRadians <= endRadians + pow(10, -10) {
            context.saveGState()
            context.rotate(by: -0.5 * .pi)
            context.rotate(by: currentRadians)
            context.translateBy(x: 0, y: radius - smallSeparatorHeight / 2)
            smallSeparatorPath.fill()
            currentRadians += smallStepRadians
            context.restoreGState()
        }
        context.restoreGState()
        
        // Indicator
        let indicatorPath = UIBezierPath()
        let firstPoint = CGPoint(x: centerPoint.x - indicatorWidth / 2, y: centerPoint.y)
        let secondPoint = CGPoint(x: centerPoint.x, y: (centerPoint.y - indicatorHeight * (1 - indicatorRate)))
        let thirdPoint = CGPoint(x: centerPoint.x + indicatorWidth / 2, y: centerPoint.y)
        let fourthPoint = CGPoint(x: centerPoint.x, y: centerPoint.y + indicatorHeight * indicatorRate)
        indicatorPath.move(to: firstPoint)
        indicatorPath.addLine(to: secondPoint)
        indicatorPath.addLine(to: thirdPoint)
        indicatorPath.addLine(to: fourthPoint)
        indicatorPath.close()
        indicatorColor.setFill()
        indicatorPath.fill()
        
        let centerPath = UIBezierPath(arcCenter: centerPoint, radius: centerRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        centerPath.lineWidth = centerRadius
        centerColor.setFill()
        centerPath.fill()
    }
    
    private func setupInitialState() {
        clearsContextBeforeDrawing = false
        isOpaque = true
        backgroundColor = .clear
        
        let upperPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        indicatorLayer.strokeEnd = CGFloat(currentValue / maxValue)
        indicatorLayer.path = upperPath.cgPath
    }
}
