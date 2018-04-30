//
//  ProductViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-05-29.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseDatabase
import FirebaseAnalytics

import MapKit

import CoreLocation

class ProductViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var qniteButton: BounceButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var vipButton: BounceButton!

    var productPage: ProductPage?
    
    var coordinates: [String: Double]?
    var venueName: String?
    var venueAddress: String?
    
    
    let manager = CLLocationManager()
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
        fetchData()
        customAnimations.Instance.applyMotionEffect(toView: backgroundImageView, magnitudex: 20, magnitudey: 20)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        descriptionLabel.alpha = 0
        facebookButton.alpha = 0
        instagramButton.alpha = 0
        logoImageView.alpha = 0
        map.alpha = 0
        vipButton.alpha = 0
        qniteButton.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        customAnimations.Instance.fadeIn(view: descriptionLabel, delay: 0.4)
        customAnimations.Instance.fadeIn(view: logoImageView, delay: 0.4)
        customAnimations.Instance.fadeIn(view: instagramButton, delay: 0.4)
        customAnimations.Instance.fadeIn(view: facebookButton, delay: 0.4)
        customAnimations.Instance.fadeIn(view: map, delay: 0.4)
        customAnimations.Instance.fadeIn(view: vipButton, delay: 1.4)
        customAnimations.Instance.fadeIn(view: qniteButton, delay: 1.4)
    }
    
    
    func fetchData() { // get venue id
        let pageId = productPage?.pageID
        DBProvider.Instance.venueInfoRef.child(pageId!).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let coordinates = data[FIR_VENUE_INFO.COORDINATES] as? [String: Double] {
                    self.coordinates = coordinates
                }
                if let name = data[FIR_VENUE_INFO.NAME] as? String {
                    self.venueName = name
                }
                if let address = data[FIR_VENUE_INFO.ADDRESS] as? String {
                    self.venueAddress = address
                }
            }
        self.setMap()
        }
    }
    
    func setMap() {
        // get coordinates of venue
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01,0.01)
        let venueLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(coordinates![FIR_VENUE_INFO.COORDINATES_LAT]!, coordinates![FIR_VENUE_INFO.COORDINATES_LONG]!)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(venueLocation, span)
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = venueLocation
        annotation.title = venueName
        annotation.subtitle = venueAddress
        map.addAnnotation(annotation)
        
    }
    
    func setBackground() {
        if let logoImageName = productPage?.logoImageName {
            logoImageView.image = UIImage(named: logoImageName)
        }
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
  
    @IBAction func QniteButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VIPSegue" {
            if let controller = segue.destination as? VIPViewController {
                controller.productPage = self.productPage
            }
        }
    }
    
}

    




    
    
