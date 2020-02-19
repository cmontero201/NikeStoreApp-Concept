
//
//  DetailTableViewController.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/22/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit
import Firebase

class DetailTableViewController: UITableViewController {
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?

        
    var shoe: shoeInstance!
    var likes = [String]()
    var cart = [String: Any]()
    
    var currentUser = Auth.auth().currentUser
    
    var favFloatingButton: UIButton?
    var cartFloatingButton: UIButton?

    let spacing: CGFloat = 15.0

    
    @IBOutlet weak var shoeImageView: shoeImageView!
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createFavFloatingButton()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard favFloatingButton?.superview != nil else {  return }
        DispatchQueue.main.async {
            self.favFloatingButton?.removeFromSuperview()
            self.favFloatingButton = nil
        }
        
        guard cartFloatingButton?.superview != nil else {  return }
        DispatchQueue.main.async {
            self.cartFloatingButton?.removeFromSuperview()
            self.cartFloatingButton = nil
        }
        let tab = self.tabBarController?.tabBar

        tab?.isHidden = false
        tab?.shadowImage = UIImage()
        tab?.backgroundColor = .white
        tab?.barTintColor = .white
        tab?.setValue(true, forKey: "hidesShadow")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        
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
        tab?.isHidden = true
        tab?.backgroundColor = .white
        
        //
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImage" {
            if let imagesPVC = segue.destination as? ImagePageViewController {
                imagesPVC.images = shoe.images
                imagesPVC.pageVCD = shoeImageView
            }
        }
        
        if segue.identifier == "showHalf" {
            if let navVC = segue.destination as? AppNavController {
                let modalVC = navVC.viewControllers.first as! ModalViewController
                
                super.prepare(for: segue, sender: self)

                print("!!!!", self.shoe.name)
                modalVC.shoe = self.shoe
                self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: segue.destination)
                
                segue.destination.modalPresentationStyle = .custom
                segue.destination.transitioningDelegate = self.halfModalTransitioningDelegate
            }
        }
    }

    
 
    
    func createFavFloatingButton() {
        let likes = self.likes
        let shoe = self.shoe
        print(likes)
        
        favFloatingButton = UIButton(type: .custom)
        favFloatingButton?.translatesAutoresizingMaskIntoConstraints = false
        favFloatingButton?.backgroundColor = .white
    
        if (likes.contains(shoe!.id!)) {
            favFloatingButton!.isSelected = true
            favFloatingButton!.setImage(UIImage(named: "favoriteAfter"), for: .selected)
        } else {
            favFloatingButton!.isSelected = false
            favFloatingButton!.setImage(UIImage(named: "favoriteBefore"), for: .normal)
            
        }
       
        favFloatingButton?.addTarget(self, action: #selector(favButtonTapped), for: .touchUpInside)
        favFloatingButton?.layer.cornerRadius = 35
        favFloatingButton?.layer.shadowColor = UIColor.black.cgColor
        favFloatingButton?.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        favFloatingButton?.layer.masksToBounds = false
        favFloatingButton?.layer.shadowRadius = 10.0
        favFloatingButton?.layer.shadowOpacity = 0.5

        
        cartFloatingButton = UIButton(type: .custom)
        cartFloatingButton?.translatesAutoresizingMaskIntoConstraints = false
        cartFloatingButton?.backgroundColor = .black
        cartFloatingButton?.setImage(UIImage(named: "cartWhite"), for: .normal)
        cartFloatingButton?.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
        cartFloatingButton?.layer.cornerRadius = 35
        cartFloatingButton?.layer.shadowColor = UIColor.black.cgColor
        cartFloatingButton?.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        cartFloatingButton?.layer.masksToBounds = false
        cartFloatingButton?.layer.shadowRadius = 10.0
        cartFloatingButton?.layer.shadowOpacity = 0.5
        
        constrainFavFloatingButtonToWindow()

    }
    
    private func constrainFavFloatingButtonToWindow() {
      
        DispatchQueue.main.async {
            guard let keyWindow = UIApplication.shared.keyWindow,
                let cartFloatingButton = self.cartFloatingButton else { return }
            keyWindow.addSubview(cartFloatingButton)
                        keyWindow.trailingAnchor.constraint(equalTo: cartFloatingButton.trailingAnchor, constant: 23).isActive = true
                        keyWindow.bottomAnchor.constraint(equalTo: cartFloatingButton.bottomAnchor, constant: 40).isActive = true
            cartFloatingButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
            cartFloatingButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
            
            
            guard let keyWindow1 = UIApplication.shared.keyWindow,
                let favFloatingButton = self.favFloatingButton else { return }
            keyWindow1.addSubview(self.favFloatingButton!)
            keyWindow1.leadingAnchor.constraint(equalTo: self.favFloatingButton!.leadingAnchor, constant: -23).isActive = true
            keyWindow1.bottomAnchor.constraint(equalTo: self.favFloatingButton!.bottomAnchor, constant: 40).isActive = true
            favFloatingButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
            favFloatingButton.heightAnchor.constraint(equalToConstant: 70).isActive = true
        }
    }
    

    
    @IBAction func favButtonTapped(sender: UIButton) -> Void {
        print("Fave Button Tapped")
        
        let db = Firestore.firestore()
        
        let selected = shoe.id
        
        if sender.isSelected == true {
            sender.isSelected = false
            sender.setImage(UIImage(named: "favoriteBefore"), for: .normal)
            
            if let index = self.likes.firstIndex(of: shoe.id!) {
                self.likes.remove(at: index)
            }
            
        } else {
            sender.isSelected = true
            sender.setImage(UIImage(named: "favoriteAfter"), for: .selected)
            self.likes.append(shoe.id!)
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
                                "likes": FieldValue.arrayRemove([selected!])
                                ])
                            
                        } else {
                            
                            let Ref = db.collection("users").document(document.documentID)
                            Ref.updateData([
                                "likes": FieldValue.arrayUnion( [selected!] )
                                ])
                        }
                    }
                }
        }
    }
    @IBAction func cartButtonTapped(sender: UIButton) -> Void {
        print("Cat Button Tapped")
        let shoe = self.shoe
        performSegue(withIdentifier: "showHalf", sender: self)

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
 
        

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "namePriceCell", for: indexPath) as! NamePriceTableViewCell
            cell.nameLabel.text = self.shoe.name! + "\n" + self.shoe.type!
            cell.priceLabel.text = "$" + String(self.shoe.price)
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sizeCell", for: indexPath) as! SizesTableViewCell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as! DescTableViewCell
            cell.descContent.text = self.shoe.desc
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            if let cell = cell as? SizesTableViewCell {
                cell.sizeCollectionView.dataSource = self
                cell.sizeCollectionView.delegate = self

                cell.sizeCollectionView.reloadData()
                cell.sizeCollectionView.isScrollEnabled = true
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return tableView.bounds.width - 325
        } else {
            return UITableView.automaticDimension
        }
    }
    

    

}

extension DetailTableViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shoe.sizes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var availSizes = [String]()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sizeCell", for: indexPath) as! SizesCollectionViewCell

        let availInventory = shoe.sizes
     
        for (size, qty) in availInventory {
            availSizes.append(size)
        }
        

        let firstDoubleArray = availSizes.map{Double($0.components(separatedBy: "").first!)!}
        availSizes = zip(availSizes, firstDoubleArray).sorted {$0.1 < $1.1}.map{$0.0}

        cell.size = availSizes[indexPath.row]

        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
   
        return CGSize(width: 55, height: 40)
    }
}



