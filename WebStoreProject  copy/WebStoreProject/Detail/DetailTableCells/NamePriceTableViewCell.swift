//
//  NamePriceTableViewCell.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/22/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit

class NamePriceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var shoe: shoeInstance! {
        didSet {
            self.set()
        }
    }
    
    func set() {
        nameLabel.text = shoe.name! + "\n" + shoe.type!
        priceLabel.text = "$" + String(shoe.price)
    }
}
