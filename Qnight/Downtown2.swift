//
//  Downtown2.swift
//  Qnight
//
//  Created by David Choi on 2017-06-07.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit

class Downtown2: UIViewController{
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    fileprivate var productPages: [ProductPage]?
    fileprivate var productPage: ProductPage?
    fileprivate var images: [UIImage] = []
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        
        scrollView.alpha = 0
        
        //Background Effects
        customAnimations.Instance.applyMotionEffect(toView: backgroundImageView, magnitudex: 20, magnitudey: 20)
        customAnimations.Instance.applyMotionEffect(toView: scrollView, magnitudex: -10, magnitudey: 4)
        // Initialize Pages/Views
        
        
        
        NotificationCenter.default.addObserver(forName: LISTENER_NAME.PAGE_LOADING_COMPLETE, object: nil, queue: nil) { (notification) in
            self.initPages()
            self.createViews()
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        scrollView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activityIndicator.stopAnimating()
        customAnimations.Instance.fadeIn(view: scrollView, delay: 0.3)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initPages() {
        productPages = initProductPages.Instance.downtownProductPages
        images = initProductPages.Instance.downtownImages
    }
    
    func createViews() {
        var arrayOfViewControllers = [UIViewController]()
        for page in productPages! {
            let vc = createVC.Instance.createViewController(productPage: page)
            arrayOfViewControllers.append(vc)
        }
        /*
        
        let arrayOfViewControllers = [
            createVC.Instance.createViewController(productPage: (productPages?[0])!),
            createVC.Instance.createViewController(productPage: (productPages?[1])!),
            createVC.Instance.createViewController(productPage: (productPages?[2])!),
            createVC.Instance.createViewController(productPage: (productPages?[3])!),
            createVC.Instance.createViewController(productPage: (productPages?[4])!),
            createVC.Instance.createViewController(productPage: (productPages?[5])!)
            ]
        */
        //Create
        let HVC = HorizontalContainerCreator.horizontalContainerWithViewControllers(arrayOfViewControllers)
        HVC.indexBarContainerView.backgroundColor = UIColor.clear
        HVC.indexBarScrollView.backgroundColor = UIColor.clear
        HVC.contentContainerView.backgroundColor = UIColor.clear
        HVC.contentScrollView.backgroundColor = UIColor.clear
        HVC.indexBarTextColor = UIColor.gray
        HVC.indexBarHighlightedTextColor = UIColor.white
        add(childViewController: HVC, toParentViewController: self)
        
        // add constraints
        HVC.view.translatesAutoresizingMaskIntoConstraints = false
        let width = NSLayoutConstraint(item: HVC.view,attribute: NSLayoutAttribute.width,relatedBy: NSLayoutRelation.equal,toItem: self.view,attribute: NSLayoutAttribute.width,multiplier: 1.0,constant: 0)
        let top = NSLayoutConstraint(item: HVC.view,attribute: NSLayoutAttribute.top,relatedBy: NSLayoutRelation.equal,toItem: self.view,attribute: NSLayoutAttribute.top,multiplier: 1,constant: 20)
        let centerX = NSLayoutConstraint(item: HVC.view, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: HVC.view, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        self.view.addConstraints([width,top,centerX,bottom])
        HVC.didMove(toParentViewController: self)
    }

    fileprivate func randomColor() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
    
    fileprivate func add(childViewController: UIViewController, toParentViewController parentViewController: UIViewController) {
        addChildViewController(childViewController)
        scrollView.addSubview(childViewController.view)
        childViewController.didMove(toParentViewController: parentViewController)
    }
    
}
