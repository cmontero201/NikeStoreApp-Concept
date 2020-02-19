//
//  shoeInstance.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/22/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseDatabase


class shoeInstance {
    var id: String?
    var name: String?
    var type: String?
    var images: [String]?
    var price: String
    var sizes: [String : Any]
    var desc: String?
    
    init(id: String, name: String, type: String, images: [String], price: String, sizes: [String : Any], desc: String) {
        self.id = id
        self.name = name
        self.type = type
        self.images = images
        self.price = price
        self.sizes = sizes
        self.desc = desc
    }
    
    class func initShoes() -> [shoeInstance] {
        var shoeInfo = [shoeInstance]()
        
        
        let shoe = shoeInstance(
            id: "001",
            name: "NMD_R1",
            type: "'Speckle Pack - White'",
            images: [ "NMDa1", "NMDa2", "NMDa3" ],
            price: "95",
            sizes: ["6": 2, "7": 2, "7.5": 4, "8": 8, "8.5": 9, "9": 6, "9.5": 4, "10": 3, "10.5": 5, "11": 2, "12": 1, "14": 2],
            desc: "THIS IS THE NMD! SO PRETTY! WAO"
            )
        
        
        let shoe2 = shoeInstance(
            id: "002",
            name: "YEEZY BOOST 350 V2",
            type: "'Black Non-Reflective'",
            images: [ "YEEZYa1","YEEZYa2", "YEEZYa3" ],
            price: "310",
            sizes: ["6": 2, "7": 2, "7.5": 4, "8": 8],
            desc: "THIS IS THE YEEZY BOOST! EXPENSIVE $$$$"
        )
            
        
        
        let shoe3 = shoeInstance(
            id: "003",
            name: "COMME DES GARÇONS X CHUCK TAYLOR ALL STAR HI",
            type: "'Milk'",
            images: [ "CONVERSE1", "CONVERSE2", "CONVERSE3" ],
            price: "140",
            sizes: [ "8.5": 9, "9": 6, "9.5": 4, "10": 3, "10.5": 3],
            desc: "DO YOU LIKE HEARTS? CAUSE THIS SHOE HAS ONE WITH EYES :)"
            )
        
        
        shoeInfo.append(shoe)
        shoeInfo.append(shoe2)
        shoeInfo.append(shoe3)
        
        
        return shoeInfo
    }
    
//    init(snapshot: DataSnapshot) {
//        _ = snapshot.key
//        let snapshotValue = snapshot.value as! [String: AnyObject]
//        id = snapshotValue["id"] as? Int
//        name = snapshotValue["name"] as? String
//        type = snapshotValue["type"] as? String
//        images = snapshotValue["images"] as? [UIImage]
//        price = snapshotValue["price"] as! Int
//        sizes = snapshotValue["sizes"] as! [String]
//        desc = snapshotValue["desc"] as? String
//        cellColor = snapshotValue["cellColor"] as? UIColor
//
//    }
}
