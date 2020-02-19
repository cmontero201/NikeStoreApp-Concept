//
//  ProductTableViewCell.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/23/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var sizeLabel: UIButton!
    @IBOutlet weak var shoeSize: UILabel!
    
    var shoe: shoeInstance! {
        didSet {
            self.update()
        }
    }
    
    func update()
    {
        productImage.image = UIImage(named: shoe.images!.first!)
        productName.text = shoe.name! + "\n" + shoe.type!
        productPrice.text = "$\(String(shoe.price))"
    }


}
