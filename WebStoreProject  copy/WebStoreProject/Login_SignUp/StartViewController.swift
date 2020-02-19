//
//  StartViewController.swift
//  WebStoreProject
//
//  Created by Christian Montero on 8/5/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBAction func goLogin(_ sender: UIButton) {
        performSegue(withIdentifier: "userLogin", sender: self)
    }
    
    @IBAction func goSignup(_ sender: UIButton) {
        performSegue(withIdentifier: "userSignup", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
