//
//  SignupViewController.swift
//  WebStoreProject
//
//  Created by Christian Montero on 8/5/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var password1: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var userSize: UITextField!
    @IBOutlet weak var signpButton: UIButton!
    
    let ref = Database.database().reference(withPath: "grocery-items")
    let db = Firestore.firestore()

    
    @IBAction func signupUser(_ sender: Any) {
        if password1.text != password2.text {
            let alertController = UIAlertController(title: "Passwords Do Not Match", message: "Please re-type password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "Password Accepted", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            Auth.auth().createUser(withEmail: userEmail.text!, password: password1.text!){ (newUser, error) in
                if error == nil {
                    
                    var dataRef: DocumentReference? = nil
                    dataRef = self.db.collection("users").addDocument(data: [
                        "id": newUser!.user.uid,
                        "name": self.userName.text!,
                        "email": self.userEmail.text!,
                        "likes": [],
                        "cart": [String: Any](),
                        "size": self.userSize.text!
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(dataRef!.documentID)")
                        }
                    }

                    self.performSegue(withIdentifier: "signupToMain", sender: self)
                }
                else{
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        performSegue(withIdentifier: "cancelSignup", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signpButton.layer.cornerRadius = 30
        userName.setBottomBorder()
        userEmail.setBottomBorder()
        userSize.setBottomBorder()
        password1.setBottomBorder()
        password2.setBottomBorder()

        // Do any additional setup after loading the view.
    }
    
}


