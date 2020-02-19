//
//  ModalViewController.swift
//  WebStoreProject
//
//  Created by Christian Montero on 8/8/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit
import Firebase

class ModalViewController: UIViewController, HalfModalPresentable, UITableViewDelegate, UITableViewDataSource {
    var shoe: shoeInstance!
    var addToCart = [String]()
    var currentUser = Auth.auth().currentUser


    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.reloadData()
        self.tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        let nav = self.navigationController?.navigationBar
        nav?.isHidden = true
        self.tableView.separatorStyle = .none

    }
    
    @IBAction func maximizeButtonTapped(sender: AnyObject) {
        maximizeToFullScreen()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func pushToCart () {
        print("ADDED")
//        cancelButtonTapped(sender: self)
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
        
        let db = Firestore.firestore()
        let selected = self.shoe.id as! String

        
        
        db.collection("users").whereField("id", isEqualTo: currentUser!.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        var currCart = document.data()["cart"]! as! [String: Any]
                        let Ref = db.collection("users").document(document.documentID)
                        
                        if (currCart[selected] != nil) {
                            var x = currCart[selected] as! [String]
                            x += self.addToCart
                            currCart[selected] = x
                            
                            Ref.updateData([
                                "cart": currCart
                            ])
                        } else if (currCart.count == 0) {
                            currCart[selected] = self.addToCart
                            
                            Ref.updateData([
                                "cart": currCart
                            ])
                        }  else {
                            currCart[selected] = self.addToCart
                            
                            Ref.updateData([
                                "cart": currCart
                                ])
                        }
                    }
                }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "halfCell", for: indexPath) as! ModalTableViewCell
            cell1.layer.cornerRadius = 8
            cell1.layer.masksToBounds = true
            cell1.shoe = self.shoe
            
            return cell1
        }  else if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "sizesHalf", for: indexPath) as! ModalTableViewCell2
            
            return cell
        } else {
            let cell3 = tableView.dequeueReusableCell(withIdentifier: "cartHalf", for: indexPath) as! ModalTableViewCell3
            cell3.cartButton.layer.cornerRadius = 15
            cell3.cartButton.frame = CGRect(x: 127, y: 18, width: 160, height: 60)
            
            cell3.cartButton.tag = indexPath.row
            cell3.cartButton.addTarget(self, action: #selector(pushToCart), for: .touchUpInside)

            return cell3
        }
    }
    
  
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            if let cell = cell as? ModalTableViewCell2 {
                cell.sizesCollection.dataSource = self
                cell.sizesCollection.delegate = self
                
                cell.sizesCollection.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return tableView.bounds.width - 225
        } else if indexPath.row == 1 {
            let num = Double(self.shoe.sizes.count)
            let numRows = ceil(num / 5.0)
            
            var cellHeight = ceil(CGFloat((65 * numRows) + 10))
            if cellHeight == 10 {
                cellHeight = 75
            }
            return cellHeight
        } else {
            return tableView.bounds.width / 4
        }
    }
        
}

extension ModalViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shoe.sizes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var availSizes = [String]()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sizesCell", for: indexPath) as! ModalCollectionViewCell
        cell.tag = 0
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.cornerRadius = 10
    
        
        let availInventory = self.shoe.sizes
        
        for (size, _) in availInventory {
            availSizes.append(size)
        }
        
        let firstDoubleArray = availSizes.map{Double($0.components(separatedBy: "").first!)!}
        availSizes = zip(availSizes, firstDoubleArray).sorted {$0.1 < $1.1}.map{$0.0}

        cell.size = availSizes[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var availSizes = [String]()
        let availInventory = self.shoe.sizes
        
        for (size, _) in availInventory {
            availSizes.append(size)
        }
        
        let firstDoubleArray = availSizes.map{Double($0.components(separatedBy: "").first!)!}
        availSizes = zip(availSizes, firstDoubleArray).sorted {$0.1 < $1.1}.map{$0.0}
        
        
        
        let selected = availSizes[indexPath.row]
        
        let cell = collectionView.cellForItem(at: indexPath) as! ModalCollectionViewCell
        
        if cell.tag == 0 {
            cell.backgroundColor = .black
            cell.sizesLabel.textColor = .white
            cell.tag = 1
            self.addToCart.append(selected)
            
        } else {
            cell.backgroundColor = .white
            cell.sizesLabel.textColor = .black
            cell.tag = 0
            if let index = addToCart.index(of: selected) {
                self.addToCart.remove(at: index)
            }

        }
        print(addToCart)

    }

    
    
}
