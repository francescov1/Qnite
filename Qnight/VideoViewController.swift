//
//  VideoViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-06-16.
//  Copyright © 2017 David Choi. All rights reserved.
//
import UIKit
import FBSDKLoginKit

class VideoViewController: VideoSplashViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var loginButton = FBSDKLoginButton()
    
    // MARK: View Did Load
    override func viewDidLoad() {
        
        super .viewDidLoad()
        
        customAnimations.Instance.applyMotionEffect(toView: backgroundImageView, magnitudex: 20, magnitudey: 20)
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore  {
            backgroundImageView.alpha = 0
            activityIndicator.alpha = 0
            self.setupVideoBackground(name: "QniteLoading", type: "mp4")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(true)
        
        if FBSDKAccessToken.current() != nil {
            
            AuthProvider.Instance.login(loginHandler: { (message) in
                if message != nil {
                    self.alertUser(title: "Problem With Login", message: message!)
                }
                else {
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            })
        }
        else {
            
            unhideButton(time: 20)
        }
        
        
    }
    
    // MARK: IBActions
    @IBAction func viewTapped(_ sender: UIButton) {
        if FBSDKAccessToken.current() == nil {
            self.showLoginButton()
        }
    }
    
    func unhideButton(time: Int){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(time), execute: {
            self.showLoginButton()
        })
    }
    
    func showLoginButton() {
        self.loginButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50) // change to constraints
        self.loginButton.delegate = self
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.delegate = self
        loginButton.readPermissions = ["public_profile","email","user_birthday"]
        self.loginView.addSubview(loginButton)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        loginButton.isHidden = true
        
        if error != nil {
            if result.declinedPermissions.contains("public_profile") {
                alertUser(title: "Problem with Login", message: "Permissions need to be accepted for Qnite to function properly")
            }
        }
        else {
            AuthProvider.Instance.login(loginHandler: { (message) in
                if message != nil {
                    self.alertUser(title: "Problem with Login", message: message!)
                    loginButton.isHidden = false
                }
                else {
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                }
            })
        }
    }
    
    // should never get here
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        _ = AuthProvider.Instance.logout()
    }
    
    private func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSegue"{
            self.tabBarController?.selectedIndex = 1
        }
    }
}

