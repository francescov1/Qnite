//
//  MenuViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-07-04.
//  Copyright © 2017 David Choi. All rights reserved.
//
import UIKit

class MenuViewController: UIViewController {
    
    // MARK: VARIABLES
    private var alcoholType: String = ""
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var MenuLabel: UILabel!
    @IBOutlet weak var buttonsView: UIView!
    // MARK: @IBACTION
    
    @IBAction func beerButton(_ sender: UIButton) {
        alcoholType = "beer"
        performSegue(withIdentifier: "menuSegue", sender: self)
    }
    
    @IBAction func bottleButton(_ sender: UIButton) {
        alcoholType = "bottle"
        performSegue(withIdentifier: "menuSegue", sender: self)
    }
    
    @IBAction func barButton(_ sender: UIButton) {
        alcoholType = "bar"
        performSegue(withIdentifier: "menuSegue", sender: self)
    }
    
    @IBAction func tapButton(_ sender: UIButton) {
        alcoholType = "tap"
        performSegue(withIdentifier: "menuSegue", sender: self)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: VIEWCONTROLLER FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        customAnimations.Instance.applyMotionEffect(toView: backgroundImageView, magnitudex: 20, magnitudey: 20)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        MenuLabel.alpha = 0
        buttonsView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        customAnimations.Instance.fadeIn(view: buttonsView, delay: 0.3)
        customAnimations.Instance.fadeIn(view: MenuLabel, delay: 0.3)
        
        if !openedMenu {
            alertUser(title: "Still in Development", message: "This section of the app currently has no funcitonality. In the future it will allow users to buy drinks in a similar method as purchasing cover!")
            openedMenu = true
        }
    }
    
    func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "menuSegue" {
            if let controller = segue.destination as? DrinksViewController {
                controller.alcoholType = self.alcoholType
            }
        }
    }
    
}
