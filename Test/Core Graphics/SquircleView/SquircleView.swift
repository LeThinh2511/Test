//
//  SquircleView.swift
//  Test
//
//  Created by Techchain on 6/23/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

@IBDesignable
class SquircleView: UIView {
    private let configuration = BezierConfiguration()
    
    @IBInspectable var color: UIColor = .white
    @IBInspectable var colorBorder: UIColor = .gray
    @IBInspectable var widthBorder: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        let height = rect.height
        let width = rect.width
        
        let topX: CGFloat = height / 7
        let topY: CGFloat = height / 9
        
        let bottomX: CGFloat = height / 10
        let bottomY: CGFloat = height / 9
        
        let topLeftPoint = CGPoint(x: topX, y: topY)
        let topCenterPoint = CGPoint(x: width / 2, y: 0)
        let topRightPoint = CGPoint(x: width - topX, y: topY)
        let centerRightPoint = CGPoint(x: width, y: height / 2)
        let bottomRightPoint = CGPoint(x: width - bottomX, y: height - bottomY)
        let bottomCenterPoint = CGPoint(x: width / 2, y: height)
        let bottmLeftPoint = CGPoint(x: bottomX, y: height - bottomY)
        let centerLeftPoint = CGPoint(x: 0, y: height / 2)
        
        let endPoints = [
            topLeftPoint,
            topCenterPoint,
            topRightPoint,
            centerRightPoint,
            bottomRightPoint,
            bottomCenterPoint,
            bottmLeftPoint,
            centerLeftPoint,
            topLeftPoint,
            topCenterPoint,
            topRightPoint,
            centerRightPoint,
            bottomRightPoint,
            bottomCenterPoint,
            bottmLeftPoint,
            centerLeftPoint,
            topLeftPoint,
            topCenterPoint,
            topRightPoint
        ]
        
        let controlPoints = configuration.configureControlPoints(data: endPoints)
        let path = UIBezierPath()
        path.lineJoinStyle = .round
        
        path.move(to: endPoints[0])
        for i in 1..<endPoints.count {
            let endPoint = endPoints[i]
            path.addCurve(to: endPoint, controlPoint1: controlPoints[i - 1].firstControlPoint, controlPoint2: controlPoints[i - 1].secondControlPoint)
        }
        
        let squircleBorderLayer = CAShapeLayer()
        squircleBorderLayer.path = path.cgPath
        squircleBorderLayer.fillColor = colorBorder.cgColor
        squircleBorderLayer.lineWidth = 0
        layer.addSublayer(squircleBorderLayer)
        
        let scaleX = (width - widthBorder) / width
        let scaleY = (height - widthBorder) / height
        let translationX = widthBorder / 2
        let squircleLayer = CAShapeLayer()
        squircleLayer.path = path.cgPath
        squircleLayer.fillColor = color.cgColor
        squircleLayer.strokeColor = UIColor.clear.cgColor
        squircleLayer.lineWidth = widthBorder
        let scale = CATransform3DMakeScale(scaleX, scaleY, 1)
        let translation = CATransform3DMakeTranslation(translationX, translationX, 0)
        squircleLayer.transform = CATransform3DConcat(scale, translation)
        layer.addSublayer(squircleLayer)
    }
}
