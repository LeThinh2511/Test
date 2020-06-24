//
//  LineChart.swift
//  Test
//
//  Created by Techchain on 6/22/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class LineChart: UIView {
    @IBInspectable var xAxisWidth: CGFloat = 1
    @IBInspectable var xAxisColor: UIColor = .white
    
    @IBInspectable var lineColor1: UIColor = .yellow
    @IBInspectable var lineColor2: UIColor = .green
    @IBInspectable var lineColor3: UIColor = .yellow
    @IBInspectable var lineWidth: CGFloat = 8
    
    @IBInspectable var fillColor: UIColor = .yellow
    
    @IBInspectable var lineShadowColor: UIColor = .black
    @IBInspectable var lineShadowOffset: CGSize = .zero
    @IBInspectable var lineShadowRadius: CGFloat = 0
    
    var xOffset: CGFloat = 4
    
    var dataSet = DataSet(entries: [], xLabels: [], yLabels: [], maxValue: 0) {
        didSet {
            setNeedsDisplay()
        }
    }
    private var startPoint: CGPoint = .zero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let colorsSpace = CGColorSpaceCreateDeviceRGB()
        context.setFillColorSpace(colorsSpace)
        drawXAxis(in: context)
        guard dataSet.entries.count > 0 else { return }
        
        let linePath = getLinePath()
        
        // Fill
        context.saveGState()
        let fillPath = linePath.copy() as! UIBezierPath
        let currentPoint = fillPath.currentPoint
        fillPath.addLine(to: CGPoint(x: currentPoint.x, y: bounds.height))
        fillPath.addLine(to: CGPoint(x: startPoint.x, y: bounds.height))
        fillPath.close()
        fillPath.addClip()
        let colors: [CGColor] = [fillColor.cgColor, fillColor.withAlphaComponent(0).cgColor]
        let fillGradient = CGGradient(colorsSpace: colorsSpace, colors: colors as CFArray, locations: [0, 1])!
        let maxEntryValue = dataSet.maxEntry?.value ?? 0
        let maxYValue = yValue(from: maxEntryValue) - lineWidth
        let startPoint = CGPoint(x: 0, y: maxYValue)
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(fillGradient, start: startPoint, end: endPoint, options: [])
        context.restoreGState()
        
        // Draw Shadow
        context.saveGState()
        let shadowPath = linePath.copy() as! UIBezierPath
        context.setShadow(offset: lineShadowOffset, blur: lineShadowRadius, color: lineShadowColor.cgColor)
        shadowPath.lineWidth = lineWidth
        UIColor.white.setStroke()
        shadowPath.lineCapStyle = .round
        shadowPath.stroke()
        context.restoreGState()
        
        // Draw the line and apply the gradient
        let lineGradient = CGGradient(colorsSpace: colorsSpace, colors: [lineColor1.cgColor, lineColor2.cgColor, lineColor3.cgColor] as CFArray, locations: [0, 0.5, 1])!
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.saveGState()
        context.addPath(linePath.cgPath)
        context.replacePathWithStrokedPath()
        context.clip()
        context.drawLinearGradient(lineGradient, start: .zero, end: CGPoint(x: frame.width, y: 0), options: [])
        context.restoreGState()
    }
    
    func drawXAxis(in context: CGContext) {
        let height = bounds.height
        let xCount = dataSet.xLabels.count
        let xAxisRect = CGRect(x: 0, y: 0, width: xAxisWidth, height: height)
        let xAxisPath = UIBezierPath(rect: xAxisRect)
        context.setFillColor(xAxisColor.cgColor)
        for i in 0..<xCount {
            let x = xValue(from: i)
            context.saveGState()
            context.translateBy(x: x, y: 0)
            xAxisPath.fill()
            context.restoreGState()
        }
    }
    
    func getLinePath() -> UIBezierPath {
        let entries = dataSet.entries
        guard let firstEntry = entries.first else {
            return UIBezierPath()
        }
        let path = UIBezierPath()
        path.lineJoinStyle = .round

        var endPoints = [CGPoint]()
        
        // Move to start point
        startPoint = CGPoint(x: xValue(from: 0), y: yValue(from: firstEntry.value) + lineWidth)
        path.move(to: startPoint)
        
        for (index, entry) in entries.enumerated() {
            let point = CGPoint(x: xValue(from: index), y: yValue(from: entry.value) + lineWidth)
            endPoints.append(point)
        }
        let configuration = BezierConfiguration()
        let controlPoints = configuration.configureControlPoints(data: endPoints)
        for i in 1..<endPoints.count {
            let endPoint = endPoints[i]
            path.addCurve(to: endPoint, controlPoint1: controlPoints[i - 1].firstControlPoint, controlPoint2: controlPoints[i - 1].secondControlPoint)
        }
        return path
    }
    
    // MARK: Helper
    func yValue(from value: Double) -> CGFloat {
        let height = bounds.height
        return height - CGFloat(value / dataSet.maxValue) * height
    }
    
    func xValue(from value: Int) -> CGFloat {
        let xCount = dataSet.xLabels.count
        let xGap = (bounds.width - 2 * self.xOffset) / (CGFloat(xCount) - 1)
        let xOffset = xAxisWidth / CGFloat(xCount - 1)
        return self.xOffset + CGFloat(value) * (xGap - xOffset)
    }
}
