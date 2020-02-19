//
//  ViewController.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/22/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginUser(_ sender: Any) {
        Auth.auth().signIn(withEmail: userEmail.text!, password: userPassword.text!) { (user, error) in
            if error == nil{
                self.performSegue(withIdentifier: "loginToMain", sender: self)
                
            }
            else{
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        performSegue(withIdentifier: "cancelLogin", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loginButton.titleLabel?.textColor = .white
        loginButton.layer.cornerRadius = 30
        userPassword.setBottomBorder()
        userEmail.setBottomBorder()
    }
}

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = UITextField.BorderStyle.none
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width,   width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
    }
}

