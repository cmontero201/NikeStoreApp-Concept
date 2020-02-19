//
//  SizesCollectionViewCell.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/22/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit

class SizesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var sizeLabel: UILabel!
    
    
    var size: String! {
        didSet {
            self.sizeLabel.text = "US " + size
            self.setNeedsLayout()
        }
    }
    
    
}
