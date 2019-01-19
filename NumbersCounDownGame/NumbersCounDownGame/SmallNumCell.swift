//
//  SmallNumCell.swift
//  NumbersCounDownGame
//
//  Created by ShamlaTech on 1/19/19.
//  Copyright © 2019 ShamlaTech. All rights reserved.
//

import UIKit

class SmallNumCell: UICollectionViewCell {
    @IBOutlet weak var numLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1.0
        self.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.height/2
    }
}
