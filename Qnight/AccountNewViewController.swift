//
//  AccountNewViewController.swift
//  Qnight
//
//  Created by Francesco Virga on 2017-06-25.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import PassKit
import FirebaseDatabase
import Stripe


class AccountNewViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var loginButtonView: UIView!
    var loginButton = FBSDKLoginButton()
    
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    let paymentCardTextField = STPPaymentCardTextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = FacebookUser.Instance.name
        showLoginButton()
        
        if LocationProvider.Instance.getAuthStatus() {
            locationButton.setTitle("✓", for: .normal)
        }
        else {
            locationButton.setTitle("✗", for: .normal)
        }
        
        NotificationProvider.Instance.getAuthStatus { (isAuth) in
            if isAuth! {
                self.notificationButton.setTitle("✓", for: .normal)
            }
            else {
                self.notificationButton.setTitle("✗", for: .normal)
            }
            // stop indicator, show content
        }
        paymentCardTextField.delegate = self
        view.addSubview(paymentCardTextField)
    }
    
    @IBAction func allowNotification(_ sender: Any) {
        let title: String
        let message: String
        if notificationButton.titleLabel?.text == "✓" {
            title = "Notifications Enabled"
            message = "In order to take advantage of all of Qnight's features, notifications need to be enabled. To change your notification preference, open Qnight in Settings."
        }
        else {
            title = "Notifications Disabled"
            message = "In order to take advantage of all of Qnight's features, notifications need to be enabled. Open Qnight in Settings and set notification permission to the 'on' position."
        }
        
        openSettingsAlert(title: title, message: message) { (action) in
            
        }
    }
    
    @IBAction func allowLocation(_ sender: Any) {
        let title: String
        let message: String
        if LocationProvider.Instance.getAuthStatus() {
            title = "Location Service Enabled"
            message = "In order to take advantage of all of Qnight's features, location services need to be enabled. To change your location preference, open Qnight in Settings."
        }
        else {
            title = "Location Service Disabled"
            message = "In order to take advantage of all of Qnight's features, location services need to be enabled. Open Qnight in Settings and set location access to 'Always'."
        }
        
        openSettingsAlert(title: title, message: message) { (action) in
            
        }
    }
    /*
     if #available(iOS 10.0, *) {
     let settingsURL = URL(string: UIApplicationOpenSettingsURLString)!
     UIApplication.shared.open(settingsURL, options: [:], completionHandler: {(success) in
     print("*** Success closure fires")
     let newAuthStatus = CLLocationManager.authorizationStatus()
     switch newAuthStatus {
     case .authorizedWhenInUse:
     self.locationManager.startUpdatingLocation()
     default:
     print("Not .authorizedWhenInUse")
     }
     })
     } else {
     if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
     UIApplication.shared.openURL(url as URL)
     }
     }
 
 */
 
    @IBAction func notificationInfo(_ sender: Any) {
        alertUser(title: "Notification Permission", message: "We use push notifications to provide you with up-to-date event information, as well as collect user feedback to improve future events.")
    }
    
    @IBAction func locationInfo(_ sender: Any) {
        alertUser(title: "Location Services Permission", message: "We use location services to ensure we always have accurate Uber estimates and to connect you with the events you're attending")
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showLoginButton() {
        self.loginButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50) // change to constraints
        self.loginButton.delegate = self
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.delegate = self
        loginButton.readPermissions = ["public_profile","email","user_birthday"]
        self.loginButtonView.addSubview(loginButton)
    }

    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        _ = AuthProvider.Instance.logout()
        self.performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
    func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func openSettingsAlert(title: String, message: String, openSettingsHandler: (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let openSettings = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: { (success) in
                    
                })
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(openSettings)
        present(alert, animated: true, completion: nil)
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        // shouldnt ever get here
    }

}

extension AccountNewViewController: STPAddCardViewControllerDelegate {
    
    func handleAddPaymentMethodButtonTapped() {
        // Setup add card view controller
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }
    
    // MARK: STPAddCardViewControllerDelegate
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        // Dismiss add card view controller
        dismiss(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        /*submitTokenToBackend(token, completion: { (error: Error?) in
            if let error = error {
                // Show error in add card view controller
                completion(error)
            }
            else {
                // Notify add card view controller that token creation was handled successfully
                completion(nil)
                
                // Dismiss add card view controller
                dismiss(animated: true)
            }
        })*/
    }

}

extension AccountNewViewController: STPPaymentCardTextFieldDelegate {
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        // Toggle buy button state
        //buyButton.enabled = textField.isValid
    }
}
