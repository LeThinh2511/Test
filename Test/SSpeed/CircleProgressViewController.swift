//
//  CircleProgressViewController.swift
//  Test
//
//  Created by Techchain on 6/3/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import Foundation
import UIKit

class CircleProgressViewController: UIViewController, CircleProgressViewDelegate, OBDMeterViewDelegate {
    @IBOutlet weak var progressView: CircleProgressView!
    @IBOutlet weak var speedMeterView: OBDMeterView!
    @IBOutlet weak var valueLabel: UILabel!
    var progress: Double = 0
    var speed: Double = 0
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.delegate = self
        speedMeterView.delegate = self
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setProgress), userInfo: nil, repeats: true)
    }
    
    @IBAction func didTapAddButton(_ sender: Any) {
//        timer?.invalidate()
//        progressView.isFailed = true
        let random = Int.random(in: -50..<50)
        progress += Double(random)
        if progress > 100 {
            progress = 100
        }
        if progress < 0 {
            progress = 0
        }
        progressView.updateValue(progress)
        
        let randomSpeed = Int.random(in: -50..<50)
        speed += Double(randomSpeed)
        if speed > 360 {
            speed = 360
        }
        if speed < 50 {
            speed = 50
        }
        speedMeterView.updateValue(speed)
    }
    
    @objc func setProgress() {
        if progress >= 90 {
            timer?.invalidate()
        }
        progress += 10
        progressView.updateValue(progress)
    }
    
    func circleProgressView(view: CircleProgressView, didUpdate value: Double) {
        valueLabel.text = "\(Int(ceil(value)))"
    }
    
    func meterView(_ view: OBDMeterView, changedValue value: Double) {
    }
}
