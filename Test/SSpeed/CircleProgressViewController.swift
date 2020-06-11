//
//  CircleProgressViewController.swift
//  Test
//
//  Created by Techchain on 6/3/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import Foundation
import UIKit

class CircleProgressViewController: UIViewController {
    @IBOutlet weak var progressView: CircleProgressView!
    var progress: Double = 0
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setProgress), userInfo: nil, repeats: true)
    }
    
    @IBAction func didTapAddButton(_ sender: Any) {
        timer?.invalidate()
        progressView.isFailed = true
    }
    
    @objc func setProgress() {
        if progress >= 90 {
            timer?.invalidate()
        }
        progress += 10
        progressView.value = progress
    }
}
