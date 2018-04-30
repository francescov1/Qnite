//
//  VIPViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-06-27.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit

class VIPViewController: UIViewController,UITextFieldDelegate  {
    
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var instagramButton: BounceButton!
    @IBOutlet weak var facebookButton: BounceButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet var VIPView: UIView!
    
    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var text2: UITextField!
    @IBOutlet weak var text3: UITextField!
    var t1: String = ""
    var t2: String = ""
    var t3: String = ""
    
    @IBOutlet weak var stackView: UIStackView!
    
    var productPage: ProductPage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupText()
        setBackground()
        addTapGesture()
        
        if productPage?.facebookHandle == "" {
            facebookButton.isHidden = true
        }
        if productPage?.instagramHandle == "" {
            instagramButton.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        stackView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fadeViewInThenOut(view: stackView, delay: 0.25)
    }
    
    
    func setupText(){
        text1.delegate = self
        text1.tag = 0
        text2.delegate = self
        text2.tag = 1
        text3.delegate = self
        text3.tag = 2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBackground() {
        if let logoImageName = productPage?.logoImageName {
            logoImageView.image = UIImage(named: logoImageName)
        }
        customAnimations.Instance.applyMotionEffect(toView: backgroundImageView, magnitudex: 20, magnitudey: 20)
    }
    
    @IBAction func QniteButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func InstagramAction() {
        let appURL = NSURL(string: "instagram://user?username=\(String(describing: productPage?.instagramHandle))")!
        let webURL = NSURL(string: "https://instagram.com/\(String(describing: productPage?.instagramHandle))")!
        let application = UIApplication.shared
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            // if Instagram app is not installed, open URL inside Safari
            application.open(webURL as URL)
        }
    }
    
    @IBAction func FacebookAction() {
        let appURL = NSURL(string: "fb://profile/\(String(describing: productPage?.facebookHandle))")!
        let webURL = NSURL(string: "https://facebook.com/\(String(describing: productPage?.facebookHandle))")!
        let application = UIApplication.shared
        if application.canOpenURL(appURL as URL) {
            application.open(appURL as URL)
        } else {
            // if Instagram app is not installed, open URL inside Safari
            application.open(webURL as URL)
        }
    }
    
    @IBAction func submitButton(_ sender: UIButton) {
        if ((text1.text?.isEmpty)! || (text2.text?.isEmpty)! || (text3.text?.isEmpty)! ){
            let alert = UIAlertController(title: "Incomplete Form", message: "Please fill out the complete form", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try again?", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            fetchTextFields()
            let alert = UIAlertController(title: "Thank You!", message: "Your request has been submitted", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "YAS", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            // send data to venue
        }
    }
    
    func fetchTextFields(){
        t1 = text1.text!
        t2 = text2.text!
        t3 = text3.text!
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    func addTapGesture(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(VIPViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func fadeViewInThenOut(view : UIView, delay: TimeInterval) {
        
        let animationDuration = 0.25
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.alpha = 0
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseInOut, animations: { () -> Void in
                view.alpha = 1
            },
                           completion: nil)
        }
    }
}
