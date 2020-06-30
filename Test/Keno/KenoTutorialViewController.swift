//
//  KenoTutorialViewController.swift
//  Test
//
//  Created by Techchain on 6/26/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class KenoTutorialViewController: UIViewController {
    enum IntroState {
        case addVehicle
        case selectService
        case schedule
    }
    
    @IBOutlet weak var introContainerView: UIView!
    
    private var currentState = IntroState.addVehicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapIntroArea(gesture:)))
        introContainerView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapIntroArea(gesture: UITapGestureRecognizer) {
        switch currentState {
        case .addVehicle:
            introContainerView.removeAllSubviews()
            showSelectServiceIntro()
            currentState = .selectService
        case .selectService:
            introContainerView.removeAllSubviews()
            showScheduleIntro()
            currentState = .schedule
        case .schedule: break
        }
    }
    
    private func showSelectServiceIntro() {
        let halfWidth = introContainerView.frame.width / 2
        let halfHeight = introContainerView.frame.height / 2
        
        let topLeftRate: CGFloat = 0.8
        let topLeftImage = UIImage(named: "car_image")
        let topLeftStart: CGPoint = .zero
        let topLeftEnd: CGPoint = CGPoint(x: halfWidth / 2, y: halfHeight / 2)
        let topLeftView = SquircleIntroView(size: topLeftRate * halfWidth, border: 8, image: topLeftImage, title: "Detailing")
        
        let topRightRate: CGFloat = 0.9
        let topRightImage = UIImage(named: "im_car_2")
        let topRightStart = CGPoint(x: introContainerView.frame.width, y: 0)
        let topRightEnd: CGPoint = CGPoint(x: halfWidth * 1.5, y: halfHeight / 2)
        let topRightView = SquircleIntroView(size: topRightRate * halfWidth, border: 10, image: topRightImage, title: "Maintenance")
        
        let bottomRate: CGFloat = 1.0
        let bottomImage = UIImage(named: "car_image")
        let bottomStart = CGPoint(x: halfWidth, y: introContainerView.frame.height)
        let bottomEnd: CGPoint = CGPoint(x: halfWidth, y: halfHeight * 1.5)
        let bottomView = SquircleIntroView(size: bottomRate * halfWidth, border: 12, image: bottomImage, title: "Car Wash")
        
        introContainerView.addSubview(topLeftView)
        introContainerView.addSubview(topRightView)
        introContainerView.addSubview(bottomView)
        topLeftView.center = topLeftStart
        topRightView.center = topRightStart
        bottomView.center = bottomStart
        topLeftView.alpha = 0
        topRightView.alpha = 0
        bottomView.alpha = 0
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            topLeftView.center = topLeftEnd
            topRightView.center = topRightEnd
            bottomView.center = bottomEnd
            topLeftView.alpha = 1
            topRightView.alpha = 1
            bottomView.alpha = 1
        }) { completed in
            bottomView.animate(delay: 0)
            topLeftView.animate(delay: 0.5)
            topRightView.animate(delay: 1)
        }
    }
    
    private func showScheduleIntro() {
        let image = UIImage(named: "im_map")
        let mapView = SquircleView(frame: introContainerView.frame, image: image)
        mapView.contentMode = .scaleAspectFill
        mapView.embed(in: introContainerView)
        mapView.shadowRadius = 8
        mapView.shadowOpacity = 0.2
        mapView.shadowColor = .black
        mapView.shadowOffset = .zero
        mapView.colorBorder = .white
        mapView.widthBorder = 10
        let transformStart = CGAffineTransform(scaleX: 0.8, y: 0.8)
        let transformEnd = CGAffineTransform(scaleX: 1.02, y: 1.02)
        mapView.alpha = 0
        mapView.transform = transformStart
        UIView.animate(withDuration: 0.4, animations: {
            mapView.transform = transformEnd
            mapView.alpha = 1
        }) { completed in
            UIView.animate(withDuration: 0.1, animations: {
                mapView.transform = .identity
            }) { completed in
                let image = UIImage(named: "ic_marker")
                let imageView = UIImageView(image: image)
                imageView.center = CGPoint(x: self.introContainerView.frame.width / 2, y: self.introContainerView.frame.height * 0.8)
                self.introContainerView.addSubview(imageView)
                imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                UIView.animate(withDuration: 0.5) {
                    imageView.transform = .identity
                }
            }
        }
    }
}
