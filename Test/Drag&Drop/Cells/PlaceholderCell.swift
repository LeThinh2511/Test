//
//  PlaceholderCell.swift
//  Test
//
//  Created by Techchain on 6/25/20.
//  Copyright © 2020 Techchain. All rights reserved.
//

import UIKit

class PlaceholderCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config(with animal: Animal?) {
        nameLabel.text = animal?.name
    }
}
