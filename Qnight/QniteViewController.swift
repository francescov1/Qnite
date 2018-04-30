//
//  QniteViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-06-08.
//  Copyright © 2017 David Choi. All rights reserved.
//
import UIKit
import FBSDKLoginKit
import CloudKit
import FirebaseDatabase
import Crashlytics

class QniteViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var qniteLogo: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var qniteSlogan: UIImageView!
    @IBOutlet weak var backDrop: UIView!
    
    
    @IBOutlet weak var carouselView: iCarousel!
    fileprivate var productPages: [ProductPage]?
    
    @IBOutlet var settingsView: UIView!
    //@IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        customAnimations.Instance.applyMotionEffect(toView: self.backgroundImageView, magnitudex: 20, magnitudey: 20)
        customAnimations.Instance.applyMotionEffect(toView: self.qniteLogo, magnitudex: 5, magnitudey: 5)
        customAnimations.Instance.applyMotionEffect(toView: self.qniteSlogan, magnitudex: -10, magnitudey: -1)
        
        createProductPages()
        createImages()
        carouselView.alpha = 0
        initSwipes()
        carouselView.reloadData()
        carouselView.type = .cylinder
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        carouselView.alpha = 0
        backDrop.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        customAnimations.Instance.fadeIn(view: carouselView, delay: 0.3)
        customAnimations.Instance.fadeIn(view: backDrop, delay: 0.2)
        activityIndicator.stopAnimating()
        
    }
    
    
    func createProductPages() {
        productPages = initProductPages.Instance.downtownProductPages + initProductPages.Instance.queensProductPages
    }
    func createImages(){
        images = initProductPages.Instance.downtownImages + initProductPages.Instance.queensImages
    }
    
    // MARK: IBAction
    
    
    @IBAction func SettingsButton(_ sender: UIButton) {
        //
        //
        //        // var pageIds = [String]()
        //        DBProvider.Instance.venueInfoRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
        //            if let data = snapshot.value as? [String: Any] {
        //                for (key,_) in data {
        //                    let token = PaymentProvider.Instance.randomSerial(length: 10)
        //                    DBProvider.Instance.venueInfoRef.child(key).child("employee_token").setValue(token)
        //                }
        //            }
        //        }
    }
    
    // MARK: ANIMATE
    func animateIn(newView: UIView) {
        self.view.addSubview(newView)
        newView.center = self.view.center
        newView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        
        newView.alpha = 0
        UIView.animate(withDuration: 0.4){
            //self.visualEffectView.isHidden = false
            newView.alpha = 1
            newView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut(newView: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            newView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            newView.alpha = 0
            //self.visualEffectView.isHidden = true
        }) { (success:Bool) in
            newView.removeFromSuperview()
        }
    }
    
    
    // MARK: LOGOUT
    
    
    
    
    // MARK: Initialize Swipes
    func initSwipes(){
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(QniteViewController.swipeAction(_:)))
        upSwipe.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(QniteViewController.swipeAction(_:)))
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(downSwipe)
    }
    
    // MARK: SWIPE ACTION
    @IBAction func swipeAction(_ sender: UISwipeGestureRecognizer) {
        if (sender.direction == .down){
            
        }
        if (sender.direction == .up){
            // performSegue(withIdentifier: "ProductSegue", sender: self)
        }
    }
    
}


extension QniteViewController  {
    // icarousel extension
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var button: UIButton? = (view as? UIButton)
        if button == nil {
            //no button available to recycle, so create new one
            let image = images[index]
            button = UIButton(type: .custom)
            button?.frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: 200, height: 200)
            button?.setImage(image, for: .normal)
            button?.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            button?.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        }
        return button!
    }
    
    func numberOfItems(in carousel: iCarousel)->Int{
        return images.count
    }
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat{
        if option == iCarouselOption.spacing{
            //print(value)
            return value * 5
        }
        return value
    }
    
    func buttonTapped(_ sender: UIButton) {
        //get item index for button
        performSegue(withIdentifier: "ProductSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductSegue" {
            if let controller = segue.destination as? ProductViewController {
                controller.productPage = productPages?[carouselView.currentItemIndex]
            }
        }
    }
    
}
