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
    
    //Counter View markers
    let context = UIGraphicsGetCurrentContext()!
      
    //1 - save original state
    context.saveGState()
    outlineColor.setFill()
        
    let markerWidth: CGFloat = 5.0
    let markerSize: CGFloat = 10.0

    //2 - the marker rectangle positioned at the top left
    let markerPath = UIBezierPath(rect: CGRect(x: -markerWidth / 2, y: 0, width: markerWidth, height: markerSize))

    //3 - move top left of context to the previous center position
    context.translateBy(x: rect.width / 2, y: rect.height / 2)
        
    for i in 1...Constants.numberOfGlasses {
      //4 - save the centred context
      context.saveGState()
      //5 - calculate the rotation angle
      let angle = angleDifference / CGFloat(Constants.numberOfGlasses) * CGFloat(i) + startAngle - .pi / 2
      //rotate and translate
      context.rotate(by: angle)
      context.translateBy(x: 0, y: rect.height / 2 - markerSize)
       
      //6 - fill the marker rectangle
      markerPath.fill()
      //7 - restore the centred context for the next rotate
      context.restoreGState()
    }

    //8 - restore the original state in case of more painting
    context.restoreGState()

  }
}
