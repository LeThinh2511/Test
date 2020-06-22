//
//  DataSet.swift
//  Test
//
//  Created by Techchain on 6/22/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import Foundation

class DataSet {
    var entries = [DataEntry]()
    var xLabels = [String]()
    var yLabels = [String]()
    
    var maxValue: Double = 0
    
    init(entries: [DataEntry], xLabels: [String], yLabels: [String], maxValue: Double) {
        self.entries = entries
        self.xLabels = xLabels
        self.yLabels = yLabels
        self.maxValue = maxValue
    }
    
    var maxEntry: DataEntry? {
        return entries.max { $0.value < $1.value }
    }
}
