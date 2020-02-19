//
//  TModalTableViewCell.swift
//  WebStoreProject
//
//  Created by Christian Montero on 8/8/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit

class ModalTableViewCell: UITableViewCell {

    @IBOutlet weak var shoeImage: UIImageView!
    @IBOutlet weak var shoeName: UILabel!
    @IBOutlet weak var shoePrice: UILabel!
    
    
    var shoe: shoeInstance! {
        didSet {
            self.update()
        }
    }
    
    func update() {
        shoeImage.image = UIImage(named: shoe.images!.first!)
        shoeName.text = shoe.name! + "\n" + shoe.type!
        shoePrice.text = "$\(String(shoe.price))"
    }
    


}
