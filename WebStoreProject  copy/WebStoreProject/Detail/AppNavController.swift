//
//  AppNavController.swift
//  WebStoreProject
//
//  Created by Christian Montero on 8/8/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit

class AppNavController: UINavigationController, HalfModalPresentable  {
    var shoe: shoeInstance!
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return isHalfModalMaximized() ? .default : .lightContent
    }
    

    
    
    
}
