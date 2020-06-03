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
    
    @IBAction func didTapAddButton(_ sender: Any) {
        progress += 10
        progressView.value = progress
    }
}
