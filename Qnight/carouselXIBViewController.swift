//
//  carouselXIBViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-06-09.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit

class carouselXIBViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {

   // fileprivate var productPages: [ProductPage]?
    var images: [UIImage] = [
        UIImage(named: "AleHouse")!,
        UIImage(named: "Stages")!,
        UIImage(named: "Brooklyn")!,
        UIImage(named: "Stone City")!,
        UIImage(named: "Trinity")!,
        UIImage(named: "Clark")!,
        UIImage(named: "QP")!,
        UIImage(named: "Underground")!
    ]
    
    @IBOutlet var carouselView: iCarousel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        productPages = [
            ProductPage(logoImageName: "AleHouse", backgroundImageName: "AleBackground", instagramHandle: "thealehouse", facebookHandle: "AleHouseAndCanteen", pageID: "/1378406678918207"),
            ProductPage(logoImageName: "Stages", backgroundImageName: "stagesbackground", instagramHandle: "thealehouse", facebookHandle: "stages.nightclub", pageID: "/1378406678918207"),
            ProductPage(logoImageName: "Brooklyn", backgroundImageName: "niceBackground", instagramHandle: "clarkhallpub", facebookHandle: "Brooklynktown", pageID: "/1378406678918207"),
            ProductPage(logoImageName: "Stone City", backgroundImageName: "niceBackground", instagramHandle: "stonecityales", facebookHandle: "stonecityaleskingston", pageID: "/1378406678918207"),
            ProductPage(logoImageName: "Trinity", backgroundImageName: "trinityBackground", instagramHandle: "stonecityales", facebookHandle: "stonecityaleskingston", pageID: "/1378406678918207"),
            ProductPage(logoImageName: "Clark", backgroundImageName: "greasepole", instagramHandle: "clarkhallpub", facebookHandle: "ClarkHallPub", pageID: "/1378406678918207"),
            ProductPage(logoImageName: "QP", backgroundImageName: "niceBackground", instagramHandle: "qp_taps", facebookHandle: "theQueensPub", pageID: "/1378406678918207"),
            ProductPage(logoImageName: "Underground", backgroundImageName: "undergroundBackground", instagramHandle: "underground_taps", facebookHandle: "queensunderground", pageID: "/1378406678918207"),
            ProductPage(logoImageName: "Hendon", backgroundImageName: "HendonBackground", instagramHandle: "hendonclothing", facebookHandle: "hendonclothing", pageID: "/1378406678918207")
        ]
        */
        
        //Carousel Effects
        carouselView.reloadData()
        carouselView.type = .cylinder
        
    }
    
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
            return value * 5
        }
        return value
    }

}
