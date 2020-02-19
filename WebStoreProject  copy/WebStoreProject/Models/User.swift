//
//  File.swift
//  WebStoreProject
//
//  Created by Christian Montero on 8/5/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import FirebaseDatabase
import FirebaseAuth

struct User {
    
    let id: String
    let name: String
    let email: String
    var likes = [String]()
    var cart = [String: Any]()
    var size: String

    
    init(id: String, name: String, email: String, likes: [String], cart: [String: Any], size: String) {
        self.id = id
        self.name = name
        self.email = email
        self.likes = likes
        self.cart = cart
        self.size = size
    }
}


