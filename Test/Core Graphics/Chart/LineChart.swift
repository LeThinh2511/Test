//
//  LineChart.swift
//  Test
//
//  Created by Techchain on 6/22/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class LineChart: UIView {
    var xAxisWidth: CGFloat = 1
    var xAxisColor: UIColor = .white
    
    var lineColor: UIColor = .red
    var lineWidth: CGFloat = 8
    
    var dataSet = DataSet(entries: [], xLabels: [], yLabels: [], maxValue: 0) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private let configuration = BezierConfiguration()
    private var startPoint: CGPoint = .zero
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawXAxis(in: context)
        
        let linePath = getLinePath()
        
        // Fill
        context.saveGState()
        let fillPath = linePath.copy() as! UIBezierPath
        let currentPoint = fillPath.currentPoint
        fillPath.addLine(to: CGPoint(x: currentPoint.x, y: bounds.height))
        fillPath.addLine(to: CGPoint(x: startPoint.x, y: bounds.height))
        fillPath.close()
        fillPath.addClip()
        let colorsSpace = CGColorSpaceCreateDeviceRGB()
        let colors: [CGColor] = [UIColor.yellow.cgColor, UIColor.yellow.withAlphaComponent(0.1).cgColor]
        let gradient = CGGradient(colorsSpace: colorsSpace, colors: colors as CFArray, locations: [0, 1])!
        let maxEntryValue = dataSet.maxEntry?.value ?? 0
        let maxYValue = yValue(from: maxEntryValue)
        let startPoint = CGPoint(x: 0, y: maxYValue)
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        context.restoreGState()
        
        // Line path
        linePath.lineWidth = lineWidth
        linePath.lineCapStyle = .round
        lineColor.setStroke()
        linePath.stroke()
    }
    
    func drawXAxis(in context: CGContext) {
        let height = bounds.height
        let width = bounds.width
        let xCount = dataSet.xLabels.count
        let xAxisRect = CGRect(x: 0, y: 0, width: xAxisWidth, height: height)
        let xAxisPath = UIBezierPath(rect: xAxisRect)
        let xGap = width / (CGFloat(xCount) - 1)
        context.setFillColor(xAxisColor.cgColor)
        let xOffset = xAxisWidth / CGFloat(xCount - 1)
        for i in 0..<xCount {
            let x = CGFloat(i) * (xGap - xOffset)
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
        startPoint = CGPoint(x: xValue(from: 0), y: yValue(from: firstEntry.value))
        path.move(to: startPoint)
        
        for (index, entry) in entries.enumerated() {
            let point = CGPoint(x: xValue(from: index), y: yValue(from: entry.value))
            endPoints.append(point)
        }
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
        let xGap = bounds.width / (CGFloat(xCount) - 1)
        let xOffset = xAxisWidth / CGFloat(xCount - 1)
        return CGFloat(value) * (xGap - xOffset)
    }
}
