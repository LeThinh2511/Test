//
//  LineChart.swift
//  Test
//
//  Created by Techchain on 6/22/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class LineChart: UIView {
    enum ValueAlignment {
        case center
        case leading
    }
    
    @IBInspectable var xAxisWidth: CGFloat = 1
    @IBInspectable var xAxisColor: UIColor = .white
    
    @IBInspectable var lineColor1: UIColor = .yellow
    @IBInspectable var lineColor2: UIColor = .green
    @IBInspectable var lineColor3: UIColor = .yellow
    @IBInspectable var lineWidth: CGFloat = 8
    
    @IBInspectable var fillColor: UIColor = .yellow
    @IBInspectable var xOffset: CGFloat = 0
    
    @IBInspectable var lineShadowColor: UIColor = .black
    @IBInspectable var lineShadowOffset: CGSize = .zero
    @IBInspectable var lineShadowRadius: CGFloat = 0
    
    var alignment: ValueAlignment = .leading {
        didSet {
            setupData()
            setNeedsDisplay()
        }
    }
    var dataSet = DataSet(entries: [], xLabels: [], yLabels: [], maxValue: 0) {
        didSet {
            setupData()
            setNeedsDisplay()
        }
    }
    private var startPoint: CGPoint = .zero
    private var xGap: CGFloat = 0
    
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
        let startPoint = CGPoint(x: 0, y: 0)
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
        var offset: CGFloat = 0
        switch alignment {
        case .center:
            offset = -xGap / 2
        case .leading:
            offset = 0
        }
        for i in 0..<xCount {
            let x = xValue(from: i) + offset
            context.saveGState()
            context.translateBy(x: x, y: 0)
            xAxisPath.fill()
            context.restoreGState()
        }
    }
    
    func getLinePath() -> UIBezierPath {
        let entries = dataSet.entries
        let path = UIBezierPath()
        path.lineJoinStyle = .round

        var endPoints = [CGPoint]()
        path.move(to: startPoint)
        for (index, entry) in entries.enumerated() {
            let point = CGPoint(x: xValue(from: index), y: yValue(from: entry.value) + lineWidth)
            endPoints.append(point)
        }
        switch alignment {
        case .center:
            let lastIndex = entries.count - 1
            guard lastIndex > 0 else { break }
            let extendedValues = getExtendedValues(dataSet: dataSet)
            let leftValue = extendedValues.left.value
            let rightValue = extendedValues.right.value
            let leftX = xValue(from: 0) - xGap / 2
            let rightX = xValue(from: lastIndex) + xGap / 2
            endPoints.append(CGPoint(x: rightX, y: yValue(from: rightValue)))
            endPoints.insert(CGPoint(x: leftX, y: yValue(from: leftValue)), at: 0)
        case .leading: break
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
    private func yValue(from value: Double) -> CGFloat {
        let height = bounds.height
        return height - CGFloat(value / dataSet.maxValue) * height
    }
    
    private func xValue(from value: Int) -> CGFloat {
        let xCount = dataSet.xLabels.count
        let axisOffset = xAxisWidth / CGFloat(xCount - 1)
        let x = xOffset + CGFloat(value) * (xGap - axisOffset)
        switch alignment {
        case .center:
            return x + xGap / 2
        case .leading:
            return x
        }
    }
    
    private func setupData() {
        // Calculate start point of the line
        switch alignment {
        case .center:
            dataSet.xLabels.append("")
            if dataSet.entries.count > 1 {
                let extendedValues = getExtendedValues(dataSet: dataSet)
                startPoint = CGPoint(x: xValue(from: 0) - xGap / 2, y: yValue(from: extendedValues.left.value))
            }
        case .leading:
            if let firstEntry = dataSet.entries.first {
                startPoint = CGPoint(x: xValue(from: 0), y: yValue(from: firstEntry.value) + lineWidth)
            }
        }
        
        // Calculate the gap between two x Axis
        let xCount = dataSet.xLabels.count
        xGap = (bounds.width - 2 * xOffset) / (CGFloat(xCount) - 1)
    }
    
    private func getExtendedValues(dataSet: DataSet) -> (left: DataEntry, right: DataEntry) {
        let entries = dataSet.entries
        let lastIndex = entries.count - 1
        guard lastIndex > 0 else {
            return (DataEntry(value: 0), DataEntry(value: 0))
        }
//        let maxValue = dataSet.maxEntry?.value ?? 0
//        let minValue = dataSet.minEntry?.value ?? 0
//        var leftValue = 2 * entries[0].value - entries[1].value
//        var rightValue = 2 * entries[lastIndex].value - entries[lastIndex - 1].value
//        leftValue = leftValue > maxValue ? maxValue : leftValue
//        leftValue = leftValue < minValue ? minValue : leftValue
//        rightValue = rightValue > maxValue ? maxValue : rightValue
//        rightValue = rightValue < minValue ? minValue : rightValue
        return (DataEntry(value: entries[0].value), DataEntry(value: entries[lastIndex].value))
    }
}
