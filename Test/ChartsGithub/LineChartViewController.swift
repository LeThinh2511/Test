//
//  LineChart1ViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit

class LineChartViewController: DemoBaseViewController {

    @IBOutlet var chartView: LineChartView!
    var dataSet: LineChartDataSet?

    override func viewDidLoad() {
        super.viewDidLoad()
        let secondColor = UIColor.hex("1D1D6B")
        let firstColor = UIColor.hex("245BB4")
        let gradients: [Gradient] = [(firstColor, 0), (secondColor, 1)]
        view.setGradients(gradients: gradients, angle: 90)

        self.title = "Line Chart 1"
        self.options = [.toggleValues,
                        .toggleFilled,
                        .toggleCircles,
                        .toggleCubic,
                        .toggleHorizontalCubic,
                        .toggleIcons,
                        .toggleStepped,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleAutoScaleMinMax,
                        .toggleData]
        
        chartView.delegate = self
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.clipDataToContentEnabled = false
        chartView.clipValuesToContentEnabled = false
        
        chartView.xAxis.spaceMin = 0.5
        chartView.xAxis.spaceMax = 0.5
        chartView.xAxis.gridLineDashLengths = [10, 0]
        chartView.xAxis.gridLineDashPhase = 0
        chartView.xAxis.labelTextColor = .white
        chartView.xAxis.axisLineColor = .clear
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .systemFont(ofSize: 13)
        chartView.xAxis.gridColor = UIColor.hex("45FFF7")
        chartView.xAxis.centerAxisLabelsEnabled = true
        
        let months = ["12", "13", "14", "15", "16", "17", "18", ""]
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawLabelsEnabled = false
        chartView.leftAxis.axisLineColor = .clear
        let leftAxis = chartView.leftAxis
        leftAxis.removeAllLimitLines()
        leftAxis.axisMaximum = 200
        leftAxis.axisMinimum = -50
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        chartView.rightAxis.enabled = false

//        let marker = BalloonMarker(color: .clear,
//                                   font: .systemFont(ofSize: 17, weight: .medium),
//                                   textColor: .white,
//                                   insets: UIEdgeInsets.zero)
//        marker.chartView = chartView
//        marker.minimumSize = CGSize(width: 80, height: 40)
//        chartView.marker = marker
        
        chartView.legend.form = .line
        
        chartView.animate(xAxisDuration: 2.5)
        updateChartData()
    }

    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        self.setDataCount(11, range: 1)
//        self.setDataCount(Int(sliderX.value), range: UInt32(sliderY.value))
    }

    func setDataCount(_ count: Int, range: UInt32) {
//        let values = (0..<count).map { (i) -> ChartDataEntry in
//            let val = Double(arc4random_uniform(range) + 3)
//            return ChartDataEntry(x: Double(i), y: val, icon: #imageLiteral(resourceName: "icon"))
//        }
        let values = (0..<7).map { (i) -> ChartDataEntry in
            var val: Double = 0
            switch i {
            case 0: val = 30
            case 1: val = 40
            case 2: val = 30
            case 3: val = 35
            case 4: val = 65
            case 5: val = 85
            case 6: val = 70
            default: val = 0
            }
            return ChartDataEntry(x: Double(i) + 0.5, y: val, icon: #imageLiteral(resourceName: "icon"))
        }
        
        let set = LineChartDataSet(entries: values, label: nil)
        set.drawIconsEnabled = false
        set.mode = .horizontalBezier
        let secondColor = UIColor.hex("45FFF7")
        let firstColor = UIColor.hex("B93BA9")
//        set1.cubicIntensity = 0.2
        set.lineCapType = .round
        set.lineDashLengths = [4, 0]
        set.highlightLineDashLengths = [2, 1]
        set.drawCirclesEnabled = false
        set.drawValuesEnabled = false
        set.drawGradientEnabled = true
        set.setColors(firstColor, secondColor)
        set.gradientPositions = [0, 1]
        set.setCircleColor(.white)
        set.lineWidth = 6
        set.circleRadius = 3
        set.drawCircleHoleEnabled = false
        set.valueFont = .systemFont(ofSize: 9)
        set.formLineDashLengths = [5, 2.5]
        set.formLineWidth = 1
        set.formSize = 0
        set.setDrawHighlightIndicators(false)
        
        let gradientColors = [ChartColorTemplates.colorFromString("#003CE3F9").cgColor,
                              ChartColorTemplates.colorFromString("#FF3CE3F9").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: [0.25, 1])!
        
        set.fillAlpha = 1
        set.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        set.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set)
        
        chartView.data = data
    }
    
    override func optionTapped(_ option: Option) {
        switch option {
        case .toggleFilled:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.drawFilledEnabled = !set.drawFilledEnabled
            }
            chartView.setNeedsDisplay()
            
        case .toggleCircles:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.drawCirclesEnabled = !set.drawCirclesEnabled
            }
            chartView.setNeedsDisplay()
            
        case .toggleCubic:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.mode = (set.mode == .cubicBezier) ? .linear : .cubicBezier
            }
            chartView.setNeedsDisplay()
            
        case .toggleStepped:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.mode = (set.mode == .stepped) ? .linear : .stepped
            }
            chartView.setNeedsDisplay()
            
        case .toggleHorizontalCubic:
            for set in chartView.data!.dataSets as! [LineChartDataSet] {
                set.mode = (set.mode == .cubicBezier) ? .horizontalBezier : .cubicBezier
            }
            chartView.setNeedsDisplay()
            
        default:
            super.handleOption(option, forChartView: chartView)
        }
    }
}

extension LineChartViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
//        let dataSetHighlight = LineChartDataSet(entries: [entry])
//        dataSetHighlight.circleRadius = 15
//        dataSetHighlight.circleHoleRadius = 8
//        dataSetHighlight.circleHoleColor = .white
//        dataSetHighlight.circleColors = [UIColor.white.withAlphaComponent(0.5)]
//        dataSetHighlight.drawCircleHoleEnabled = true
//        dataSetHighlight.valueFont = .systemFont(ofSize: 0)
//        dataSetHighlight.valueTextColor = .white
//        dataSetHighlight.highlightLineWidth = 0
//        dataSetHighlight.drawIconsEnabled = false
//
//        if let dataSetCount = chartView.data?.dataSetCount, dataSetCount > 1 {
//            chartView.data?.dataSets.removeLast()
//        }
//        chartView.data?.dataSets.append(dataSetHighlight)
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
//        if let dataSetCount = chartView.data?.dataSetCount, dataSetCount > 1 {
//            chartView.data?.dataSets.removeLast()
//        }
    }
}
