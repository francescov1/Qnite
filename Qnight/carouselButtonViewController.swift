//
//  carouselButtonViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-06-09.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit

class carouselButtonViewController: UIViewController, iCarouselDataSource, iCarouselDelegate  {
    
    var images: [UIImage] = [
        UIImage(named: "AleHouse")!,
        UIImage(named: "Stages")!,
        UIImage(named: "Brooklyn")!,
        UIImage(named: "Stone City")!,
        UIImage(named: "Trinity")!,
        UIImage(named: "Clark")!,
        UIImage(named: "QP")!,
        UIImage(named: "Underground")!,
        UIImage(named: "Hendon1")!
    ]
    
    @IBOutlet var carouselView: iCarousel!


    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //configure carousel
        carouselView.type = .coverFlow2
        
        carouselView.reloadData()
        carouselView.type = .cylinder
        
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var button: UIButton? = (view as? UIButton)
        if button == nil {
            //no button available to recycle, so create new one
            let image = #imageLiteral(resourceName: "AleHouse")
            button = UIButton(type: .custom)
            button?.frame = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat((image.size.width)), height: CGFloat((image.size.height)))
            button?.setTitleColor(UIColor.black, for: .normal)
            button?.setBackgroundImage(image, for: .normal)
            button?.titleLabel?.font = button?.titleLabel?.font?.withSize(CGFloat(50))
            button?.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        }
        //set button label
        button?.setTitle("\(index)", for: .normal)
        return button!
    }
    
    func buttonTapped(_ sender: UIButton) {
        //get item index for button
        let index: Int = carouselView.index(ofItemViewOrSubview: sender)
        print("\(index)")
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
