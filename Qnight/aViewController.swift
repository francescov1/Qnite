//
//  aViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-05-30.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit

class aViewController: UIViewController {

    
    // MARK: VIEWDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Swipe Handle
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(aViewController.swipeAction(_:)))
        upSwipe.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(aViewController.swipeAction(_:)))
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(aViewController.swipeAction(_:)))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(aViewController.swipeAction(_:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)
        
        // Snow
        snowBlur(with: #imageLiteral(resourceName: "goldblur"))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func swipeAction(_ sender: UISwipeGestureRecognizer) {
        if (sender.direction == .right){
            performSegue(withIdentifier: "ab", sender: self)
        }
    }
    
    
    // MARK: Make it Snow
    
    func snowBlur(with image: UIImage){
        let emitter = Emitter.get(with: image)
        emitter.emitterPosition = CGPoint(x: view.frame.width / 2, y: 0)
        emitter.emitterSize = CGSize(width: view.frame.width, height: 2)
        view.layer.addSublayer(emitter)
    }



}
