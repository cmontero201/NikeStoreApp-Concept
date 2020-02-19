//
//  DescTableViewCell.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/22/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit

class DescTableViewCell: UITableViewCell {
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var descContent: UILabel!
    
    var shoe: shoeInstance! {
        didSet {
            self.set()
        }
    }
    
    func set() {
        descLabel.text = "Description"
        descContent.text = shoe.desc
    }
}
