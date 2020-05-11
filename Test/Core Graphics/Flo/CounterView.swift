//
//  CounterView.swift
//  Test
//
//  Created by Techchain on 5/11/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

@IBDesignable
class CounterView: UIView {
  private struct Constants {
    static let numberOfGlasses = 8
    static let lineWidth: CGFloat = 5.0
    static let arcWidth: CGFloat = 76
    
    static var halfOfLineWidth: CGFloat {
      return lineWidth / 2
    }
  }
  
  @IBInspectable var counter: Int = 5 {
    didSet {
      if counter <=  Constants.numberOfGlasses {
        setNeedsDisplay()
      }
    }
  }
  @IBInspectable var outlineColor: UIColor = UIColor.blue
  @IBInspectable var counterColor: UIColor = UIColor.orange
  
  override func draw(_ rect: CGRect) {
    let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
    let radius = max(bounds.width, bounds.height)
    let startAngle: CGFloat = 3 * .pi / 4
    let endAngle: CGFloat = .pi / 4
    let path = UIBezierPath(
      arcCenter: center,
      radius: radius/2 - Constants.arcWidth/2,
      startAngle: startAngle,
      endAngle: endAngle,
      clockwise: true)
    path.lineWidth = Constants.arcWidth
    counterColor.setStroke()
    path.stroke()
    
    let angleDifference: CGFloat = 2 * .pi - (startAngle - endAngle)
    let completedAngle = CGFloat(counter) * angleDifference / CGFloat(Constants.numberOfGlasses)
    let completedEndAngle = completedAngle + startAngle
    
    let outerArcRadius = bounds.width/2 - Constants.halfOfLineWidth
    let completedArcPath = UIBezierPath(
        arcCenter: center,
        radius: outerArcRadius,
        startAngle: startAngle,
        endAngle: completedEndAngle,
        clockwise: true)
    
    let innerArcRadius = bounds.width/2 - Constants.arcWidth + Constants.halfOfLineWidth
    completedArcPath.addArc(
        withCenter: center,
        radius: innerArcRadius,
        startAngle: completedEndAngle,
        endAngle: startAngle,
        clockwise: false)
    
    completedArcPath.close()
    
    completedArcPath.lineWidth = Constants.lineWidth
    outlineColor.setStroke()
    completedArcPath.stroke()
  }
}
