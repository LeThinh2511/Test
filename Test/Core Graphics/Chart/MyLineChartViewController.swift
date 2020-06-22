//
//  MyLineChartViewController.swift
//  Test
//
//  Created by Techchain on 6/22/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class MyLineChartViewController: UIViewController {
    @IBOutlet weak var chartView: LineChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let xLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let yLabels = ["0", "10", "20", "30", "40", "50", "60", "70"]
        let entries = [
            DataEntry(value: 13),
            DataEntry(value: 45),
            DataEntry(value: 23),
            DataEntry(value: 42),
            DataEntry(value: 32),
            DataEntry(value: 19),
            DataEntry(value: 55)
        ]
        let dataSet = DataSet(entries: entries, xLabels: xLabels, yLabels: yLabels, maxValue: 70)
        chartView.dataSet = dataSet
    }
}
