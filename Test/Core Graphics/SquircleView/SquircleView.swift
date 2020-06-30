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
    
    @IBInspectable var colorFill: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var colorBorder: UIColor = .gray {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var widthBorder: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var image: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    convenience init(frame: CGRect, image: UIImage?) {
        self.init(frame: frame)
        self.image = image
        setupUI()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let height = bounds.height
        let width = bounds.width
        let offset = shadowRadius
        
        let topX: CGFloat = height / 10 + offset
        let topY: CGFloat = height / 8 + offset
        
        let bottomX: CGFloat = height / 11 + offset
        let bottomY: CGFloat = height / 9 + offset
        
        let topLeftPoint = CGPoint(x: topX, y: topY)
        let topCenterPoint = CGPoint(x: width / 2, y: offset)
        let topRightPoint = CGPoint(x: width - topX, y: topY)
        let centerRightPoint = CGPoint(x: width - offset, y: height / 2)
        let bottomRightPoint = CGPoint(x: width - bottomX, y: height - bottomY)
        let bottomCenterPoint = CGPoint(x: width / 2, y: height - offset)
        let bottomLeftPoint = CGPoint(x: bottomX, y: height - bottomY)
        let centerLeftPoint = CGPoint(x: offset, y: height / 2)
        
        let endPoints = [
            topLeftPoint,
            topCenterPoint,
            topRightPoint,
            centerRightPoint,
            bottomRightPoint,
            bottomCenterPoint,
            bottomLeftPoint,
            centerLeftPoint,
            topLeftPoint,
            topCenterPoint,
            topRightPoint,
            centerRightPoint,
            bottomRightPoint,
            bottomCenterPoint,
            bottomLeftPoint,
            centerLeftPoint,
            topLeftPoint,
            topCenterPoint,
            topRightPoint,
            centerRightPoint,
        ]
        
        let controlPoints = configuration.configureControlPoints(data: endPoints)
        let path = UIBezierPath()
        path.lineJoinStyle = .round
        
        path.move(to: endPoints[0])
        for i in 1..<endPoints.count {
            let endPoint = endPoints[i]
            path.addCurve(to: endPoint, controlPoint1: controlPoints[i - 1].firstControlPoint, controlPoint2: controlPoints[i - 1].secondControlPoint)
        }
        
        colorBorder.setFill()
        path.fill()
        
        context.addPath(path.cgPath)
        context.clip()
        
        context.saveGState()
        let spacing = widthBorder
        let scaleX = (width - spacing * 2) / width
        let scaleY = (height - spacing * 2) / height
        let translationX = (width - width * scaleX) / 2
        let translationY = (height - height * scaleY) / 2
        context.translateBy(x: translationX, y: translationY)
        context.scaleBy(x: scaleX, y: scaleY)
        colorFill.setFill()
        path.fill()
        context.restoreGState()
        
        path.apply(CGAffineTransform(scaleX: scaleX, y: scaleY))
        path.apply(CGAffineTransform(translationX: translationX, y: translationY))
        
        context.addPath(path.cgPath)
        context.clip()
        
        if let image = image?.cgImage {
            let size = getNewSize(image: image)
            let origin = CGPoint(x: -size.width / 2, y: -size.height / 2)
            let frame = CGRect(origin: origin, size: size)
            context.translateBy(x: width, y: height)
            context.rotate(by: .pi)
            context.translateBy(x: width / 2, y: height / 2)
            context.draw(image, in: frame)
        }
    }
    
    func getNewSize(image: CGImage) -> CGSize {
        let imageWidth = CGFloat(image.width)
        let imageHeight = CGFloat(image.height)
        switch contentMode {
        case .scaleAspectFit:
            let hfactor: CGFloat = imageWidth / bounds.width
            let vfactor: CGFloat = imageHeight / bounds.height
            let factor = max(hfactor, vfactor)
            let newWidth = imageWidth / factor
            let newHeight = imageHeight / factor
            return CGSize(width: newWidth, height: newHeight)
        default:
            // scaleAspectFill
            let aspect = imageWidth / imageHeight
            if bounds.width / aspect > bounds.height {
                let height = bounds.width / aspect
                return CGSize(width: bounds.width, height: height)
            } else {
                let width = bounds.height * aspect
                return CGSize(width: width, height: bounds.height)
            }
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
    }
}
