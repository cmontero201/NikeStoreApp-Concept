//
//  ModalCollectionViewCell.swift
//  WebStoreProject
//
//  Created by Christian Montero on 8/9/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit

class ModalCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var sizesLabel: UILabel!
        
    var size: String! {
        didSet {
            self.sizesLabel.text = "US " + size
            self.setNeedsLayout()
        }
    }
        
}

