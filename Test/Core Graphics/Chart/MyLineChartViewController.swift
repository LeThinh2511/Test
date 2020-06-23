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
    
    private var entries = [DataEntry]()
    private let xLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let yLabels = ["0", "10", "20", "30", "40", "50", "60", "70"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataSet = DataSet(entries: entries, xLabels: xLabels, yLabels: yLabels, maxValue: 70)
        chartView.dataSet = dataSet
    }
    
    @IBAction func didTapUpdateValue(_ sender: Any) {
        addNewValue()
    }
    
    private func addNewValue() {
        let value = Double.random(in: 20...70)
        let entry = DataEntry(value: value)
        if entries.count >= 7 {
            entries.removeFirst()
        }
        entries.append(entry)
        var strings = "["
        for entry in entries {
            strings += "\(Int(entry.value)) "
        }
        strings += "]"
        print(strings)
        let dataSet = DataSet(entries: entries, xLabels: xLabels, yLabels: yLabels, maxValue: 70)
        chartView.dataSet = dataSet
    }
}
