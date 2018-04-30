//
//  EventViewViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-06-08.
//  Copyright © 2017 David Choi. All rights reserved.
//
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseDatabase
import UserNotifications

class EventViewViewController: UIViewController {
    
    var currentEventRef: DatabaseReference? = nil
    
    var productPage: ProductPage?
    var amountGoing: Int = 0
    var currentVenueID: String = ""
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLocationLabel: UILabel!
    @IBOutlet weak var goingLabel: UILabel!
    @IBOutlet weak var switchOutlet: UISwitch!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initiallyHide()
        
        currentVenueID = productPage!.pageID
        currentEventRef = DBProvider.Instance.eventRef.child(currentVenueID).child(Constants.Instance.getDateInDBFormat())
        
        fetchEventInfo()
        fetchEventData()
        observeChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initiallyHide()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchEventInfo()
        fetchEventData()
        welcomeRequest()
    }
    
    func welcomeRequest() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore  {
            let message = "Welcome to the first testing version of Qnite! Play around with the app and tell us what you think. If you have any suggestions or encounter any bugs/crashes, don't hesitate to message us so we can fix them before the official launch. Also, feel free to try out the Apple Pay button; you won't get charged! (Apple Wallet still needs to be set up) \nEnjoy 🤗🎉"
            var title = "Welcome!"
            
            if let name = FacebookUser.Instance.name {
                title = "Hey \(name.components(separatedBy: " ")[0])!"
            }
            
            alertUser(title: title, message: message, completion: { (_) in
                LocationProvider.Instance.requestAuth()
                NotificationProvider.Instance.requestAuth()
                UserDefaults.standard.set(true, forKey: "launchedBefore")
            })
        }
        else {
            if !LocationProvider.Instance.getAuthStatus() {
                LocationProvider.Instance.requestAuth()
            }
            NotificationProvider.Instance.getAuthStatus(handler: { (isAuth) in
                if !isAuth! {
                    NotificationProvider.Instance.requestAuth()
                }
            })
        }
    }
    
    // MARK: @IBACTION Functions
    
    @IBAction func `switch`(_ sender: UISwitch) {
        let userID = FacebookUser.Instance.id
        var handle: UInt?
        if sender.isOn == true {
            currentEventRef?.child(FIR_EVENT_DATA.USERS_ATTENDING).child(userID!).child(FIR_EVENT_DATA.FEEDBACK).setValue("NA")
            
            let day: Int?
            let currentHour = DATE_FORMATTER_HOUR.string(from: Date())
            
            if Int(currentHour)! < 12 {
                day = 1
            }
            else {
                day = nil
            }
            
            NotificationProvider.Instance.activateCalendarNotification(title: "How was \(self.productPage?.name ?? "your night") last night?", body: "Let us know so we can improve future events!", categoryID: NOTIFICATION_ID.CATEGORY_POST_EVENT, requestID: currentVenueID, minute: 0, hour: 12, day: day)
      
            handle = currentEventRef?.child(FIR_EVENT_DATA.USERS_ATTENDING).child(userID!).observe( .childAdded, with: { (snapshot: DataSnapshot) in
                if snapshot.key == FIR_EVENT_DATA.COVER_ID {
                    self.switchOutlet.isEnabled = false
                }
            })
        }
        else {
            currentEventRef?.child(FIR_EVENT_DATA.USERS_ATTENDING).child(userID!).removeValue()
            NotificationProvider.Instance.removeLocalNotification(requestIDs: [currentVenueID])
            if handle != nil {
                currentEventRef?.child(FIR_EVENT_DATA.USERS_ATTENDING).child(userID!).removeObserver(withHandle: handle!)
            }
        }
    }
    
    func fetchEventData() {
        currentEventRef?.child(FIR_EVENT_DATA.USERS_ATTENDING).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? [String: Any] {
                self.amountGoing = data.count
                if let userData = data[FacebookUser.Instance.id!] as? [String: Any] {
                    self.switchOutlet.setOn(true, animated: true)
                    if userData[FIR_EVENT_DATA.COVER_ID] != nil {
                        self.switchOutlet.isEnabled = false
                    }
                }
            }
            self.setGoing()
        })
    }
    
    func fetchEventInfo() {
        FBProvider.Instance.fetchEventData(pageID: currentVenueID) { (eventData: [String: String]?) in
            if eventData != nil {
                self.nameLabel.text = eventData?[FIR_EVENT_INFO.NAME] ?? "No event name"
                self.timeLocationLabel.text = "\(eventData![FIR_EVENT_INFO.START_TIME] ?? "Time not available") @ \(eventData![FIR_EVENT_INFO.LOCATION] ?? "Location not available 😕")"
                self.descriptionTextField.text = eventData![FIR_EVENT_INFO.DESCRIPTION] ?? "No event description 🤷‍♂️"
                self.showAll()
            }
        }
    }
    
    func observeChanges() {
        currentEventRef?.child(FIR_EVENT_DATA.USERS_ATTENDING).observe( .childAdded, with: { (snapshot: DataSnapshot) in
            self.currentEventRef?.child(FIR_EVENT_DATA.USERS_ATTENDING).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                if let data = snapshot.value as? [String: Any] {
                    self.amountGoing = data.count
                    self.setGoing()
                }
            })
        })
        
        currentEventRef?.child(FIR_EVENT_DATA.USERS_ATTENDING).observe( .childRemoved, with: { (snapshot: DataSnapshot) in
            self.currentEventRef?.child(FIR_EVENT_DATA.USERS_ATTENDING).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                if let data = snapshot.value as? [String: Any] {
                    self.amountGoing = data.count
                }
                else {
                    self.amountGoing = 0
                }
                self.setGoing()
            })
        })
        
        
    }
    
    func setGoing() {
        var label: String
        
        if self.switchOutlet.isOn {
            if self.amountGoing == 1 {
                label = "1 person going 🤗🎉"
            }
            else {
                label = "\(self.amountGoing) people going 🤗🎉"
            }
        }
        else {
            if self.amountGoing == 1 {
                label = "1 person is going, will you?"
            }
            else {
                label = "\(self.amountGoing) people are going, will you?"
            }
        }
        self.goingLabel.text = label
    }
    
    fileprivate func add(childViewController: UIViewController, toParentViewController parentViewController: UIViewController) {
        addChildViewController(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParentViewController: parentViewController)
    }
    
    private func initiallyHide(){
        self.timeLocationLabel.isHidden = true
        self.goingLabel.isHidden = true
        self.switchOutlet.isHidden = true
        self.nameLabel.isHidden = true
        self.descriptionTextField.isHidden = true
    }
    
    private func showAll(){
        self.timeLocationLabel.isHidden = false
        self.goingLabel.isHidden = false
        self.switchOutlet.isHidden = false
        self.nameLabel.isHidden = false
        self.descriptionTextField.isHidden = false
    }
    
    func alertUser(title: String, message: String, completion: @escaping (UIAlertAction) -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Dismiss", style: .default, handler: completion)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
