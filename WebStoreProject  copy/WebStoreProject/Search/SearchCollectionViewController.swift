//
//  SearchTableViewController.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/23/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit
import Firebase


class SearchCollectionViewController: UICollectionViewController {

    var shoeList: [shoeInstance]?
    var shoePass: shoeInstance!
    var searchResult: [shoeInstance]?

    var likes: [shoeInstance]?
    
    var filtered:[String] = []
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var noResult: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.isActive = true

        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.sizeToFit()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchController.searchBar.becomeFirstResponder()
        
        
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
        
        
    }
    
    func getData() {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        DispatchQueue.global().async {
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
                        print("HERE",hold)
                        self.shoeList = hold
                        self.searchResult = hold
                        self.collectionView.reloadData()
                    }
                    self.shoeList = holder
                    pushData(arr: holder)
                }
                dispatchGroup.leave()
                
            }
            dispatchGroup.notify(queue: .main) {
                print("done")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "fromSearch") {
            if let detailTableVC = segue.destination as? DetailTableViewController {
                detailTableVC.shoe = shoePass
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        }
        else
        {
            return searchResult?.count ?? 0
        }
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchCollectionViewCell
        
        cell.shoeName.text = searchResult![indexPath.row].name! + "\n" + searchResult![indexPath.row].type!
        cell.shoePrice.text = "$" + String(searchResult![indexPath.row].price)
        cell.shoeImage.image = UIImage(named: (searchResult![indexPath.row].images?.first!)!)
        
        return cell
    }
    

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.shoePass = searchResult![indexPath.row]
        self.performSegue(withIdentifier: "fromSearch", sender: indexPath)
    }
    
   

}

extension SearchCollectionViewController: UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UICollectionViewDelegateFlowLayout {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        noResult.text = ""

        self.dismiss(animated: true, completion: nil)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if (searchController.searchBar.text?.count)! > 0 {
            guard let searchText = searchController.searchBar.text?.lowercased(),
                searchText != "" else {
                    return
            }
            
            let result = shoeList!.filter { ($0.name?.lowercased().contains(searchText))! }.compactMap { $0 }
            
            searchResult = result
            
            if searchResult!.count == 0{
                noResult.text = "No Results"
            }
        
            self.collectionView.reloadData()
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchActive = true
        noResult.text = ""
        collectionView.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        noResult.text = ""

        collectionView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        
        collectionView.reloadData()
    }

        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
            
        let width = 0.4998 * screenWidth
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
            edgeInsets.top = 0
        
        return edgeInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 1)
    }

}
