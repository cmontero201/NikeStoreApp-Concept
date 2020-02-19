//
//  CheckoutTableViewController.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/23/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit
import Firebase


class CartTableViewController: UITableViewController {
    
    var db: Firestore!
    
    var shoeList: [shoeInstance]?
    var shoePass: shoeInstance!
    var shoes: [cartShoe]?

    var userList: [User]?
    var currentUser = Auth.auth().currentUser
    var userInfo: User! = nil
    
    var cart = [String]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        getData()

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        
        self.tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        
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
        self.tableView.reloadData()
        self.tableView.separatorStyle = .none

    }
    
    func getData() {
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
                        self.tableView.reloadData()
                        
                    }

                    self.shoeList = holder
                    pushData(arr: holder)
                    self.getCart()
                    
                }
                dispatchGroup.leave()
                
            }
            dispatchGroup.notify(queue: .main) {
                print("done1")
            }
        }
    }
    
    
    func getCart() {
        var holder = [cartShoe]()
        let db = Firestore.firestore()
        
        db.collection("users").whereField("id", isEqualTo: self.currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        var currCart = document.data()["cart"]! as! [String: Any]
                        
                        for var shoeId in currCart {
                            var key = shoeId.key
                            for shoeSize in (shoeId.value as! [String]) {
                                var x = cartShoe(id: key, size: shoeSize, qty: 1)
                                holder.append(x)
                            }
                        }
                    }
                }
                func setShoes(arr: [cartShoe]) {
                    self.shoes = arr
                    self.tableView.reloadData()
                }
                setShoes(arr: holder)
                self.shoes = holder
        }
    }
    
    
    @objc func removeButtonTapped(sender: UIButton) -> Void {
        let db = Firestore.firestore()
        
        let selected = shoes?[sender.tag].id
        let selectedSize = shoes?[sender.tag].size

        db.collection("users").whereField("id", isEqualTo: currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        var currCart = document.data()["cart"]! as! [String: Any]
                        
                        for shoeId in currCart {
                            let key = shoeId.key
                            for shoeSize in (shoeId.value as! [String]) {
                                if (selected == key && selectedSize == shoeSize) {
                                    var car = currCart[key] as! [String]
                                    if let index = car.firstIndex(of: selectedSize!) {
                                        car.remove(at: index)
                                        currCart[selected!] = car
                                    }
                                }
                            }
                        }
                        let Ref = db.collection("users").document(document.documentID)

                        Ref.updateData([
                            "cart": currCart
                            ])

                            self.getData()

                            self.tableView.reloadData()
                        }
                    }
                }
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.shoes)
        if shoes != nil {
            return self.shoes!.count + 3
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var subtot: Double = 0
        
        guard let shoes = shoes else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCountCell", for: indexPath) as! ItemNumTableViewCell
            cell.itemCountLabel.text = "\(0) ITEM"
            
            return cell
        }
        
        if indexPath.row == 0 {
            // itemCountCell
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "itemCountCell", for: indexPath) as! ItemNumTableViewCell
            cell1.layer.cornerRadius = 8
            cell1.layer.masksToBounds = true
            cell1.itemCountLabel.text = "\(self.shoes!.count) ITEMS"
            
            return cell1
        } else if indexPath.row == self.shoes!.count + 1 {
            // subtotalCell
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "subtotalCell", for: indexPath) as! SubtotalTableViewCell
            cell2.layer.cornerRadius = 8
            cell2.layer.masksToBounds = true
            
            var idArr = [String]()
            for ind in self.shoes! {
                idArr.append(ind.id!)
            }
            
            var sub = 0
            for shoe in shoeList! {
                for id in idArr {
                    if shoe.id == id {
                        sub += Int(shoe.price)!
                    }
                }
            }
            let tax = Double(sub) * 0.075
            
            cell2.subtotal.text = "$" + String(format: "%.2f", Double(sub))
            cell2.tax.text = "$" + String(format: "%.2f", tax)
            
            return cell2
        } else if indexPath.row == self.shoes!.count + 2 {
            // totalCell
            let cell3 = tableView.dequeueReusableCell(withIdentifier: "totalCell", for: indexPath) as! TotalTableViewCell
            cell3.layer.cornerRadius = 8
            cell3.layer.masksToBounds = true
            
            var idArr = [String]()
            for ind in self.shoes! {
                idArr.append(ind.id!)
            }
            
            var sub = 0
            for shoe in shoeList! {
                for id in idArr {
                    if shoe.id == id {
                        sub += Int(shoe.price)!
                    }
                }
            }
            
            let tax = Double(sub) * 0.075
            
            let total = Double(sub) + tax
            
            cell3.total.text = "$" + String(format: "%.2f", total)
            
            return cell3
        } else {
            // productCell
            let cell4 = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell

            var tshoe = self.shoes![indexPath.row - 1].id
            
            for shoe in shoeList! {
                if tshoe == shoe.id {
                    cell4.shoe = shoe
                }
            }
            
            cell4.shoeSize.text = self.shoes![indexPath.row - 1].size
            
        
            cell4.layer.cornerRadius = 8
            cell4.layer.masksToBounds = true
            
            let removeButton = cell4.removeButton
            removeButton!.tag = indexPath.row - 1
            removeButton!.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)

            return cell4
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return tableView.bounds.width - 350
        } else {
            return UITableView.automaticDimension
        }
    }

}

class cartShoe {
    var id: String?
    var size: String
    var qty: Int
    
    init(id: String, size: String, qty: Int) {
        self.id = id
        self.size = size
        self.qty = qty
    }
}
