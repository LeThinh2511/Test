//
//  SquircleIntroView.swift
//  Test
//
//  Created by Techchain on 6/26/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class SquircleIntroView: CustomView {
    @IBOutlet weak var outerSquircleView: SquircleView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    
    var image: UIImage?
    var title: String?
    var widthBorder: CGFloat = 0
    var colorBorder: UIColor = .white
    
    convenience init(size: CGFloat, border: CGFloat = 0, borderColor: UIColor = .white, image: UIImage? = nil, title: String? = nil) {
        self.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        self.image = image
        self.title = title
        self.widthBorder = border
        self.colorBorder = borderColor
        setupUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func animate(delay: TimeInterval) {
        let center = titleLabel.center
        titleLabel.center.y = center.y + titleLabel.frame.height
        UIView.animate(withDuration: 0.4, delay: delay, animations: {
            self.titleLabel.alpha = 1
            self.titleLabel.center.y = center.y
        }) { completed in
            UIView.animate(withDuration: 0.1) {
                self.iconImageView.alpha = 1
            }
        }
    }
    
    private func setupUI() {
        outerSquircleView.shadowColor = .lightGray
        outerSquircleView.shadowRadius = 4
        outerSquircleView.shadowOpacity = 0.2
        outerSquircleView.shadowOffset = .zero
        outerSquircleView.image = image
        outerSquircleView.widthBorder = widthBorder
        outerSquircleView.colorBorder = colorBorder
        titleLabel.text = title
        titleLabel.alpha = 0
        iconImageView.alpha = 0
    }
}
