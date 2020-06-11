//
//  CoreAnimationViewController.swift
//  Test
//
//  Created by Techchain on 6/10/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class CoreAnimationViewController: UIViewController {
    @IBOutlet weak var animatedView: UIView!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var purpleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapAnimateButton(_ sender: Any) {
        animatedView.layer.opacity = 0
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.duration = 2.0
        animatedView.layer.add(opacityAnimation, forKey: "opacity")
        
        let transition = CATransition()
        transition.startProgress = 0
        transition.endProgress = 1.0
        transition.type = .reveal
        transition.subtype = .fromBottom
        transition.duration = 4
        
        greenView.layer.add(transition, forKey: "transition")
        purpleView.layer.add(transition, forKey: "transition")
        
        greenView.isHidden = true
        purpleView.isHidden = false
    }
}
