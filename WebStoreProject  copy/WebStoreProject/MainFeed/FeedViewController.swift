//
//  FeedViewController.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/22/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit
import Firebase


class FeedViewController: UICollectionViewController {
    
    var db: Firestore!
    
    var shoeList: [shoeInstance]?
    var shoePass: shoeInstance!
    
    var userList: [User]?
    var currentUser = Auth.auth().currentUser
    var userInfo = [User]()
    
    
    var likes = [String]()
    var cart = [String: Any]()
    var size = ""
    
    
    override func viewWillAppear(_ animated: Bool) {
        let dispatchGroup = DispatchGroup()
        getData()
        dispatchGroup.wait()
        dispatchGroup.notify(queue: DispatchQueue.global()) {
            print("DONEEE")
        }
        dispatchGroup.suspend()
    
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.reloadData()
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.orange]

       


        // Make Navigation Bar borderless white with Swoosh image as title
        let nav = self.navigationController?.navigationBar
        let tab = self.tabBarController?.tabBar
        let image: UIImage = UIImage(named: "swoosh")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50 , height: 50))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
        nav?.backgroundColor = .white
        nav?.barTintColor = .white
        tab?.barTintColor = .white
        nav?.setValue(true, forKey: "hidesShadow")
        tab?.setValue(true, forKey: "hidesShadow")
        tab?.shadowImage = UIImage()
        tab?.backgroundColor = .white
        tab?.isHidden = false

        //
        
        self.collectionView.reloadData()
        
    }
    

    func getData( ) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let db = Firestore.firestore()
            
            db.collection("shoeInventory").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var holder = [shoeInstance]()
                    var count = 0
                    for item in querySnapshot!.documents {
                        count += 1
                        
                        var dataObject = item.data()
                        let id = dataObject["id"]
                        let name = dataObject["name"]
                        let type = dataObject["type"]
                        let images = dataObject["images"] as! [String?]
                        let price = dataObject["price"]
                        let sizes = dataObject["sizes"]! as! [String?: Any]
                        let desc = dataObject["desc"]
                        
                        let prod = shoeInstance(id: id as! String, name: (name!) as! String, type: (type!) as! String, images: (images) as! [String], price: (price!) as! String, sizes: sizes as! [String : Any], desc: (desc!) as! String)
                        
                        holder.append(prod)
                    }
                    
                    func pushData(arr: [shoeInstance]) {
                        let hold = arr
                        self.shoeList = hold
                        self.collectionView.reloadData()
                    }
                    self.shoeList = holder
                    pushData(arr: holder)
                    ()
                }
                //                dispatchGroup.leave()
                
            }
            dispatchGroup.notify(queue: .main) {
                print("done1")
                
                
                db.collection("users").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        var holder = [User]()
                        var count = 0
                        if querySnapshot!.documents.count == 0 {
                            print("EMPTY")
                            
                        } else {
                            for item in querySnapshot!.documents {
                                count += 1
                                
                                var dataObject = item.data()
                                let id = dataObject["id"]
                                let name = dataObject["name"]
                                let email = dataObject["email"]
                                let likes = dataObject["likes"]
                                let cart = dataObject["cart"]
                                let size = dataObject["size"]
                                
                                
                                let prod = User(id: id as! String, name: name as! String, email: email as! String, likes: likes as! [String], cart: cart as! [String: Any], size: size as! String)
                                
                                holder.append(prod)
                            }
                            
                            func pushUserData(arr: [User]) {
                                let hold = arr
                                self.userList = hold
                                
                                self.collectionView.reloadData()
                            }
                            
                            func push( arr: [User]) {
                                for ind in arr {
                                    if ind.id == self.currentUser!.uid {
                                    }
                                }
                                self.collectionView.reloadData()
                            }
                            
                            self.userList = holder
                            pushUserData(arr: holder)
                            push(arr: holder)
                        }
                        //                    dispatchGroup.leave()
                    }
                    
                    
                }
            }
            dispatchGroup.leave()
            dispatchGroup.wait()

        }
        dispatchGroup.wait()
        
        dispatchGroup.notify(queue: .main) {
            print("done2")
        }
    }
    

    
    @IBAction func favButtonTapped(sender: UIButton) -> Void {
        let db = Firestore.firestore()

        let selected = shoeList?[sender.tag].id as! String
        
        if sender.isSelected == true {
            sender.isSelected = false
//            sender.setImage(UIImage(named: "favoriteBefore"), for: .normal)

        } else {
            sender.isSelected = true
//            sender.setImage(UIImage(named: "favoriteAfter"), for: .selected)
            
        }
        
        db.collection("users").whereField("id", isEqualTo: currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.likes = document.data()["likes"]! as! [String]
                        
                        if (self.likes.contains{ $0 == selected }) {
                            
                            let Ref = db.collection("users").document(document.documentID)

                            Ref.updateData([
                                    "likes": FieldValue.arrayRemove([selected])
                            ])
                            
                        } else {

                            let Ref = db.collection("users").document(document.documentID)
                            Ref.updateData([
                                "likes": FieldValue.arrayUnion( [selected] )
                            ])
                        }
                    }
                }
        }
        getData()
        self.collectionView.reloadData()
    }


    @IBAction func cartButtonTapped(sender: UIButton) -> Void {
        let db = Firestore.firestore()
        
        let selected = shoeList?[sender.tag].id as! String
        let size = self.userInfo[0].size
        
        if sender.isSelected == true {
            sender.isSelected = false
            
        } else {
            sender.isSelected = true
            
        }
        
        db.collection("users").whereField("id", isEqualTo: currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print(document.data()["cart"]!)
                        print(self.cart)
                        self.cart = document.data()["cart"]! as! [String: Any]
                        let Ref = db.collection("users").document(document.documentID)

                        
                        if (self.cart[selected] != nil) {
                            var current = self.cart
                            var new = current[selected] as! [String]
                            if let index = new.firstIndex(of: size) {
                                new.remove(at: index)
                            }
                           
                            current[selected] = new
                            
                            if new.count == 0 {
                                current.removeValue(forKey: selected)
                            }
                            self.cart = current
                            Ref.updateData([
                                "cart": self.cart
                                ])
                            
                        } else if (self.cart.count == 0) {
                            self.cart = [selected: [size]]
                            Ref.updateData([
                                "cart": self.cart
                                ])
                            
                        } else {
                            var current = self.cart
                            current[selected] = [size]

                            self.cart = current
                            Ref.updateData([
                                "cart": self.cart
                                ])
                            }
                        }
                    }
                }
        
        getData()
        self.collectionView.reloadData()

    }
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDetail") {
            if let detailTableVC = segue.destination as? DetailTableViewController {
                let selectedShoe = self.shoeList?[(sender as! IndexPath).row]
                
                let userLikes = self.userInfo[0].likes
                let userCart = self.userInfo[0].cart
                detailTableVC.shoe = selectedShoe
                detailTableVC.likes = userLikes
                detailTableVC.cart = userCart
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shoeList?.count ?? 0
    }
    

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FeedCollectionViewCell
        cell.contentView.layer.backgroundColor = UIColor.lightGray.cgColor
        if (indexPath.row % 2 == 0 || indexPath.row == 0) {
            cell.contentView.layer.backgroundColor = CGColor(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 0.7559742647))
        } else if (indexPath.row % 3 == 0) {
            cell.contentView.layer.backgroundColor = CGColor(#colorLiteral(red: 0.721585989, green: 0.8823689222, blue: 0.9319705963, alpha: 0.75))
        } else {
            cell.contentView.layer.backgroundColor = CGColor(#colorLiteral(red: 0.9588789344, green: 0.8257604241, blue: 0.8850416541, alpha: 0.75))
        }
        cell.contentView.layer.cornerRadius = 10.0
        cell.contentView.layer.masksToBounds = true
        
        for ind in self.userList! {
            if ind.id == currentUser?.uid {
                self.userInfo = [ind]
            }
        }
        
        self.cart = self.userInfo[0].cart
        self.likes = self.userInfo[0].likes
        self.size = self.userInfo[0].size
    
        
        cell.id = (shoeList?[indexPath.row].id)!
        cell.shoeName.text = (shoeList?[indexPath.row].name)! + "\n" + (shoeList?[indexPath.row].type)!
        cell.shoeImage.image = UIImage(named: (shoeList?[indexPath.row].images?[0])!)
        let hold = shoeList?[indexPath.row].price
        cell.shoePrice.text = "$" + hold!.description
        
        if self.likes.contains(cell.id) {
            cell.favButton.setImage(UIImage(named: "favoriteAfter"), for: .selected)
            cell.favButton.isSelected = true
        }else{
            cell.favButton.setImage(UIImage(named: "favoriteBefore"), for: .normal)
            cell.favButton.isSelected = false
        }
        
        if self.userInfo[0].cart[cell.id] != nil {
            cell.cartButton.setImage(UIImage(named: "cartAfter"), for: .selected)
            cell.cartButton.isSelected = true
        }else{
            cell.cartButton.setImage(UIImage(named: "cartBefore"), for: .normal)
            cell.cartButton.isSelected = false
        }

        cell.favButton.tag = indexPath.row
        cell.favButton.addTarget(self, action: #selector(favButtonTapped), for: .touchUpInside)
        
        cell.cartButton.tag = indexPath.row
        cell.cartButton.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        
        

        return cell
    }
    

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetail", sender: indexPath)
    }
    
}



extension FeedViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let width = 0.88 * screenWidth
        let height = 0.45 * screenHeight
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }
    
}
