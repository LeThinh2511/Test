//
//  CustomView.swift
//  Test
//
//  Created by Techchain on 6/26/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class CustomView: UIView {
    @IBOutlet weak var contentView: UIView!
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        initiate()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initiate()
    }
    
    private func initiate() {
        Bundle.main.loadNibNamed(className, owner: self, options: nil)
        contentView.embed(in: self)
    }
}
