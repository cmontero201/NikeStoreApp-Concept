//
//  ImagePageViewController.swift
//  WebStoreProject
//
//  Created by Christian Montero on 7/22/19.
//  Copyright © 2019 Christian Montero. All rights reserved.
//

import UIKit

protocol ImagesPageViewControllerDelegate: class {
    func setPageController(numberOfPages: Int)
    func turnPageController(to index: Int)
}

class ImagePageViewController: UIPageViewController {
    
//    var images: [UIImage]? = shoeInstance.initShoes().first!.images!
    var images: [String]? = []

    weak var pageVCD: ImagesPageViewControllerDelegate?
    
    lazy var controllers: [UIViewController] = {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var controllers = [UIViewController]()
        
        if let images = self.images {
            for image in images {
                let imageVC = storyboard.instantiateViewController(withIdentifier: "ImageViewController")
                
                controllers.append(imageVC)
            }
        }
        
        self.pageVCD?.setPageController(numberOfPages: controllers.count)
        
        return controllers
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        
        self.turnToPage(index: 0)
    }
    
    
    func turnToPage(index: Int)
    {
        let controller = controllers[index]
        var direction = UIPageViewController.NavigationDirection.forward
        
        if let currentVC = viewControllers?.first {
            let currentIndex = controllers.firstIndex(of: currentVC)!
            if currentIndex > index {
                direction = .reverse
            }
        }
        
        self.configureDisplaying(viewController: controller)
        
        setViewControllers([controller], direction: direction, animated: true, completion: nil)
    }
    
    func configureDisplaying(viewController: UIViewController)
    {
        for (index, vc) in controllers.enumerated() {
            if viewController === vc {
                if let imageVC = viewController as? ImageViewController {
                    imageVC.image = UIImage(named: (self.images?[index])!)
                    
                    self.pageVCD?.turnPageController(to: index)
                }
            }
        }
    }
}

extension ImagePageViewController : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController) {
            if index > 0 {
                return controllers[index-1]
            }
        }
        
        return controllers.last
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController) {
            if index < controllers.count - 1 {
                return controllers[index + 1]
            }
        }
        
        return controllers.first
    }
}

extension ImagePageViewController : UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.configureDisplaying(viewController: pendingViewControllers.first as! ImageViewController)
      
        

    }
        
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        if !completed {
            self.configureDisplaying(viewController: previousViewControllers.first as! ImageViewController)
        }
    }
}
