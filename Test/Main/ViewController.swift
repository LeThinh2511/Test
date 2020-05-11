//
//  ViewController.swift
//  Test
//
//  Created by Techchain on 1/9/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var gradientView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let secondColor = UIColor.hex("45FFF7")
        let firstColor = UIColor.hex("B93BA9")
        let gradients: [Gradient] = [(firstColor, 0), (secondColor, 1)]
        gradientView.setGradients(gradients: gradients)
        
        gradientView.shadowColor = UIColor.black
        gradientView.shadowRadius = 10
        gradientView.shadowOpacity = 0.5
        gradientView.shadowOffset = CGSize(width: 0, height: 0)
        gradientView.masksToBounds = false
        gradientView.cornerRadius = 20
    }
    
    @IBAction func didTapViewChart(_ sender: Any) {
        let view = LineChartViewController()
        navigationController?.pushViewController(view, animated: true)
    }
}
