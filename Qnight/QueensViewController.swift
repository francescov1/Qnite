//
//  CarouselViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-05-28.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit

class QueensViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {
    
    fileprivate var productPages: [ProductPage]?
    
    var images: [UIImage] = [
        UIImage(named: "Clark2")!,
        UIImage(named: "queensPubLogo")!,
        UIImage(named: "underground")!,
        UIImage(named: "Hendon")!
    ]
    
    @IBOutlet var carouselView: iCarousel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var QniteImageView: UIImageView!
    @IBOutlet weak var whatsgoingImageView: UIImageView!
    @IBOutlet weak var r1: UIImageView!
    @IBOutlet weak var r2: UIImageView!
    @IBOutlet weak var g1: UIImageView!
    @IBOutlet weak var g2: UIImageView!
    @IBOutlet weak var c1: UIImageView!
    @IBOutlet weak var c2: UIImageView!
    @IBOutlet weak var c3: UIImageView!
    
    // MARK: VIEWDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Background Effects
        applyMotionEffect(toView: backgroundImageView, magnitudex: 100, magnitudey: 20)
        applyMotionEffect(toView: r1, magnitudex: -40, magnitudey: -20)
        applyMotionEffect(toView: r2, magnitudex: 30, magnitudey: -10)
        applyMotionEffect(toView: g1, magnitudex: 30, magnitudey: 20)
        applyMotionEffect(toView: g2, magnitudex: 40, magnitudey: -20)
        applyMotionEffect(toView: c1, magnitudex: -20, magnitudey: 10)
        applyMotionEffect(toView: c2, magnitudex: -15, magnitudey: -20)
        applyMotionEffect(toView: c3, magnitudex: 10, magnitudey: 30)
        applyMotionEffect(toView: whatsgoingImageView, magnitudex: -20, magnitudey: 0)
        
        //Carousel Effects
        carouselView.reloadData()
        carouselView.type = .cylinder
        
        //Product Organizers
        productPages = [
            ProductPage(logoImageName: "clarklogo", backgroundImageName: "greasepole", instagramHandle: "clarkhallpub", facebookHandle: "ClarkHallPub", pageID: "/1378406678918207"),
            ProductPage(logoImageName: "queensPubLogo", backgroundImageName: "blurbarBackground", instagramHandle: "qp_taps", facebookHandle: "theQueensPub", pageID: "/1378406678918207"),
            ProductPage(logoImageName: "undergroundName", backgroundImageName: "undergroundBackground", instagramHandle: "underground_taps", facebookHandle: "queensunderground", pageID: "/1378406678918207"),
            ProductPage(logoImageName: "Hendon2", backgroundImageName: "HendonBackground", instagramHandle: "hendonclothing", facebookHandle: "hendonclothing", pageID: "/1378406678918207"),
        ]
        
//         Swipe Handle
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(QueensViewController.swipeAction(_:)))
        upSwipe.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(QueensViewController.swipeAction(_:)))
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(downSwipe)
        
    }
    
    // MARK: CAROUSEL FUNC
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?)->UIView{
        let tempView = UIView(frame: CGRect(x:0,y:0,width:200,height:200))
        
        let frame = CGRect(x:0,y:0,width:200,height:200)
        let imageView = UIImageView()
        imageView.frame = frame
        imageView.contentMode = .scaleAspectFit
        
        imageView.image = images[index]
        tempView.addSubview(imageView)
        return tempView
    }
    func numberOfItems(in carousel: iCarousel)->Int{
        return images.count
    }
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat{
        if option == iCarouselOption.spacing{
            print(value)
            return value * 2.5
        }
        return value
    }
    
    @IBAction func swipeAction(_ sender: UISwipeGestureRecognizer) {
        if (sender.direction == .down){
            self.dismiss(animated: true, completion: nil)
        }
        if (sender.direction == .up){
            performSegue(withIdentifier: "QueensSegue", sender: self)
        }
        
    }
    
    
    // MARK: VIEW TRANSFER
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "QueensSegue" {
            if let controller = segue.destination as? ProductViewController {
                controller.productPage = productPages?[carouselView.currentItemIndex]
            }
        }
    }
    
    // MARK: MOTION FX FUNC
    func applyMotionEffect (toView view: UIView, magnitudex:Float, magnitudey: Float){
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitudex
        xMotion.maximumRelativeValue = magnitudex
        
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongHorizontalAxis)
        yMotion.minimumRelativeValue = -magnitudey
        yMotion.maximumRelativeValue = magnitudey
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [xMotion, yMotion]
        
        view.addMotionEffect(group)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
