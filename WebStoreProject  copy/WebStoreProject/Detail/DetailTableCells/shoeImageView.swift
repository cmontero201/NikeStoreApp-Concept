//
//  ImageView.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/22/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit

class shoeImageView: UIView {

    @IBOutlet weak var pageControl: UIPageControl!
    
}

extension shoeImageView : ImagesPageViewControllerDelegate {
    func setPageController(numberOfPages: Int) {
        pageControl.numberOfPages = numberOfPages
    }
    
    func turnPageController(to index: Int) {
        pageControl.currentPage = index
    }
}
