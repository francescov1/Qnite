//
//  ProductContainerViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-06-07.
//  Copyright © 2017 David Choi. All rights reserved.
//
import UIKit
import UberRides
import CoreLocation

import FBSDKCoreKit
import FirebaseDatabase
import FirebaseAnalytics
import PassKit


open class ProductContainerViewController: UIViewController, RideRequestButtonDelegate {
    
    // MARK: VARIABLES
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var payButton: BounceButton!
    @IBOutlet weak var instaButton: BounceButton!
    @IBOutlet weak var fbButton: BounceButton!
    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var coverLabel: UILabel!
    
    var productPage: ProductPage?
    var eventController: EventViewViewController?
    
    let ridesClient = RidesClient()
    let uberButton = RideRequestButton()
    
    var serial: String?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        changeOrder()
        if let logoImageName = productPage?.logoImageName {
            logoImageView.image = UIImage(named: logoImageName)
        }
        if productPage?.instagramHandle == "" {
            instaButton.isHidden = true
        }
        if productPage?.facebookHandle == "" {
            fbButton.isHidden = true
        }
        
        addEventViewController()
        
        uberButton.delegate = self
        checkPayment(showQR: false)
        addObservers()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        initUberButton()
        qrView.isHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func payAction(_ sender: Any) {
        if serial != nil { // already bought cover
            if qrView.isHidden == false {
                qrView.isHidden = true
            }
            else {
                PaymentProvider.Instance.generateQRCode(fbID: FacebookUser.Instance.id!, QRImageView: qrImageView, pageId: (self.productPage?.pageID)!, completion: { (image) in
                    
                    if image != nil {
                        self.qrImageView.image = image!
                        self.qrView.isHidden = false
                        self.uberButton.isHidden = false
                    }
                })
            }
        }
        else { // hasn't bought cover
            PaymentProvider.Instance.payAction(viewController: self, pageId: (self.productPage?.pageID)!, pageName: (self.productPage?.name)!)
        }
    }
    
    
    func addObservers() {
        NotificationCenter.default.addObserver(forName: LISTENER_NAME.LOCATION, object: nil, queue: nil) { (notification) in
            if let currentLocation = notification.object as? CLLocation {
                self.updateButton(pickupLocation: currentLocation)
            }
        }
        NotificationCenter.default.addObserver(forName: LISTENER_NAME.PAYMENT_COVER, object: nil, queue: nil) { (notification) in
            self.checkPayment(showQR: true)
        }
    }
    
    func checkPayment(showQR: Bool) {
        eventController?.currentEventRef?.child(FIR_EVENT_DATA.USERS_ATTENDING).child(FacebookUser.Instance.id!).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? [String: Any] {
                if let serial = data[FIR_EVENT_DATA.COVER_ID] as? String {
                    self.serial = serial
                    self.coverLabel.text = "View Cover QR Code"
                    
                    if showQR {
                        self.payButton.sendActions(for: .touchUpInside)
                    }
                    //self.payButton.setImage(#imageLiteral(resourceName: "qrcode"), for: UIControlState.normal)
                }
            }
        })
    }
    
    func updateButton(pickupLocation: CLLocation) {
        if !(productPage?.coordinates.isEmpty)! {
            let lat = productPage?.coordinates[FIR_VENUE_INFO.COORDINATES_LAT]
            let long = productPage?.coordinates[FIR_VENUE_INFO.COORDINATES_LONG]
            let dropoffLocation = CLLocation(latitude: lat!, longitude: long!)
            let venueName = self.productPage?.name
            let builder = RideParametersBuilder().setPickupLocation(pickupLocation).setDropoffLocation(dropoffLocation, nickname: venueName)
            
            ridesClient.fetchCheapestProduct(pickupLocation: pickupLocation, completion: { product, response in
                if let productID = product?.productID {
                    _ = builder.setProductID(productID)
                    self.uberButton.rideParameters = builder.build()
                    self.uberButton.loadRideInformation()
                }
            })
        }
    }
    
    func initUberButton() {
        uberButton.translatesAutoresizingMaskIntoConstraints = false
        uberButton.clipsToBounds = true
        view.addSubview(uberButton)
        
        uberButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        uberButton.topAnchor.constraint(equalTo: logoImageView.bottomAnchor).isActive = true
        uberButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        uberButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        uberButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
    
    public func rideRequestButtonDidLoadRideInformation(_ button: RideRequestButton) {
        //        button.sizeToFit()
    }
    
    public func rideRequestButton(_ button: RideRequestButton, didReceiveError error: RidesError) {
        // error handling
    }
    
    func addEventViewController() {
        eventController = EventViewViewController()
        eventController?.productPage = self.productPage
        self.add(childViewController: eventController!, toParentViewController: self)
    }
    
    fileprivate func setupContentView() {
        let vcViews = viewController.map { vc -> UIView in
            addChildViewController(vc)
            vc.didMove(toParentViewController: self)
            return vc.view
        }
        
        self.view.addViewsHorizontally(vcViews)
        
        NSLayoutConstraint.activate(
            vcViews.map { vcView -> NSLayoutConstraint in
                vcView.widthAnchor.constraint(equalTo: view.widthAnchor)
        })
        
        
        scrollView.setHorizontalContentOffsetWithinBounds(0)
    }
    
    fileprivate func removeContentView() {
        viewController.forEach { vc in
            vc.willMove(toParentViewController: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
    }
    
    // MARK: VIEW CONTROLLER
    open var viewController: [UIViewController] = [] {
        willSet {
            removeContentView()
        }
        
        didSet {
            setupContentView()
        }
    }
    
    fileprivate func add(childViewController: UIViewController, toParentViewController parentViewController: UIViewController) {
        addChildViewController(childViewController)
        scrollView.addSubview(childViewController.view)
        childViewController.didMove(toParentViewController: parentViewController)
        
    }
    
    func changeOrder(){
        payButton.layer.zPosition = 1
        coverLabel.layer.zPosition = 2
        qrView.layer.zPosition = 3
        uberButton.layer.zPosition = 4
    }
    
    @IBAction func instagramAction(_ sender: UIButton ) {
        let handle = productPage?.instagramHandle
        let appURL = URL(string: "instagram://user?username=" + handle!)!
        let webURL = URL(string: "https://instagram.com/" + handle!)!
        let application = UIApplication.shared
        if application.canOpenURL(appURL) {
            application.open(appURL)
        } else {
            // if Instagram app is not installed, open URL inside Safari
            application.open(webURL)
        }
    }
    @IBAction func facebookAction(_ sender: UIButton) {
        let handle = productPage?.facebookHandle
        let appURL = URL(string: "fb://profile/" + handle!)!
        let webURL = URL(string: "https://facebook.com/" + handle!)!
        let application = UIApplication.shared
        if application.canOpenURL(appURL) {
            application.open(appURL)
        } else {
            // if Instagram app is not installed, open URL inside Safari
            application.open(webURL)
        }
    }
    
    @IBAction func qrViewWasTapped(_ sender: UITapGestureRecognizer) {
        self.qrView.isHidden = true
    }
    
    func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
}
