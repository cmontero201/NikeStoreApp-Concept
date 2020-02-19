//
//  FeedCollectionViewCell.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/22/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell {
    var id: String!
    @IBOutlet weak var shoeImage: UIImageView!
    @IBOutlet weak var shoeName: UILabel!
    @IBOutlet weak var shoePrice: UILabel!
    
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var cartButton: UIButton!
    
    
    var shoe: shoeInstance! {
        didSet {
            self.set()
        }
    }
    
    func set() {
        var images = shoe.images!
        shoeImage.image = UIImage(named: images[0])
        shoeName.text = shoe.name! + shoe.type!
        shoePrice.text = "$" + String(shoe.price)
        favButton.isSelected = false
        cartButton.isSelected = false
        
        
        favButton.setImage(UIImage(named: "favortieBefore"), for: .normal)
        favButton.setImage(UIImage(named: "favoriteAfter"), for: .selected)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cartButton.setImage(UIImage(named: "cartBefore"), for: .normal)
        favButton.setImage(UIImage(named: "favoriteBefore"), for: .normal)

    }
    
   

    
    // MAYBE SHOULD BE ACTION FUNCTIONS??

    
}
