//
//  bViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-05-30.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit

class bViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Swipe Handle
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(bViewController.swipeAction(_:)))
        upSwipe.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(bViewController.swipeAction(_:)))
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(bViewController.swipeAction(_:)))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(bViewController.swipeAction(_:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func swipeAction(_ sender: UISwipeGestureRecognizer) {
        if (sender.direction == .left){
            performSegue(withIdentifier: "ba", sender: self)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
