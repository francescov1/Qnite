//
//  DrinksViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-07-10.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit

class DrinksViewController: UIViewController {

    // MARK: Attributes
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var menuLabel: UILabel!
    
    
    @IBOutlet weak var buttonsView: UIScrollView!
    
    var alcoholType: String = ""
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    @IBOutlet weak var image6: UIImageView!
    @IBOutlet weak var image7: UIImageView!
    @IBOutlet weak var image8: UIImageView!
    
    
    // MARK: VIEW FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
//        customAnimations.Instance.applyMotionEffect(toView: backgroundImageView, magnitudex: 20, magnitudey: 20)
//        setLabel()
        setAlcoholImages()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        buttonsView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        customAnimations.Instance.fadeIn(view: buttonsView, delay: 0.3)

    }
    
    // MARK: FUNCTIONS
    
    private func setLabel(){
        switch (alcoholType){
        case "beer":
            menuLabel.text = "Beer Menu"
        case "bar":
            menuLabel.text = "Mixed Drinks Menu"
        case "bottle":
            menuLabel.text = "Bottle Service Menu"
        case "tap":
            menuLabel.text = "Tap Menu"
        default:
            print("error")
        }
    }
    
    private func setAlcoholImages(){
        var images: [UIImageView] = [
            image1,image2,image3,image4,image5,image6,image7,image8
        ]
        
        var imageSet: [UIImage] = alcoholTypes.Instance.alcoholTypeImages(type: alcoholType)
        
        var i = 0
        while i < 8{
            images[i].image = imageSet[i]
            i += 1
        }
        
    }

    
    // MARK: IBACTION
    
    @IBAction func backButton(_ sender: BounceButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
