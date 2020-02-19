//
//  SearchCollectionViewController.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/23/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit
import Firebase

class FavoriteCollectionViewController: UICollectionViewController {
    @IBOutlet weak var isEmpty: UILabel!
    
    var db: Firestore!
    
    var userList: [User]?
    var shoeList: [shoeInstance]?
    var shoePass: shoeInstance!
    
    var currentUser = Auth.auth().currentUser
    var userInfo: User! = nil
    
    
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
        
        DispatchQueue.global(qos: .background).async {
            
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
                                        self.userInfo = ind
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
        }
        dispatchGroup.wait()
        
        dispatchGroup.notify(queue: .main) {
            print("done2")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "fromLikes") {
            if let detailTableVC = segue.destination as? DetailTableViewController {
                detailTableVC.shoe = shoePass
            }
        }
    }
    


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userInfo?.likes.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> FavoriteCollectionViewCell {
        let sizesString: String?
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteCell", for: indexPath) as! FavoriteCollectionViewCell
  
//        cell.layer.borderColor = UIColor.lightGray.cgColor
//        cell.layer.borderWidth = 1
        
        
        var shoeSizes = [String : Any]()
    
        if userInfo.likes.count == 0 {
            print("NO FAVORITES ADDED TO TO LIST")
        } else {
            let ind = Int(userInfo.likes[indexPath.row])! - 1
            
            cell.favoriteName.text = (shoeList?[ind].name)! + "\n" + (shoeList?[ind].type)!
            cell.favoriteImage.image = UIImage(named: (shoeList?[ind].images?[0])!)
            let hold = shoeList?[ind].price
            cell.favoritePrice.text = "$" + hold!.description
            shoeSizes = ((shoeList?[ind].sizes)!)
            if shoeSizes != nil {
                print(shoeSizes)
                var sortedSizes = shoeSizes.map { Float($0.key)!}
                sortedSizes = sortedSizes.sorted()
                let sizeArray = sortedSizes.map { "US " + String($0) }
                sizesString = sizeArray.prefix(5).joined(separator:"   ")
                if sizeArray.count > 5 {
                    cell.moreLabel.isHidden = false
                }
                
                
                cell.sizesLabel.text = sizesString
                cell.sizesLabel.font = UIFont.boldSystemFont(ofSize: 16)
//                cell.sizesLabel.lineBreakMode = .byWordWrapping
//                cell.sizesLabel.numberOfLines = 3
                
                cell.sizesLabel.contentMode = .scaleToFill
                cell.sizesLabel.numberOfLines = 0
                cell.sizesLabel.layoutMargins.left = CGFloat(5)
                cell.sizesLabel.layoutMargins.right = CGFloat(5)
            }
        
        }

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          let ind = Int(userInfo.likes[indexPath.row])! - 1
        self.shoePass = shoeList![ind]
        self.performSegue(withIdentifier: "fromLikes", sender: indexPath)
    }
    

}

extension FavoriteCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let width = 0.88 * screenWidth
        let height = 0.38 * screenHeight
        
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.01
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.01
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        var edgeInsets = UIEdgeInsets()
        edgeInsets.top = 1
        
        return edgeInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 1)
    }
}
