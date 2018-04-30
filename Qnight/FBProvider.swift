//
//  File.swift
//  Qnight
//
//  Created by Francesco Virga on 2017-06-12.
//  Copyright © 2017 David Choi. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import Crashlytics

class FBProvider {
    private static let _instance = FBProvider()
    static var Instance: FBProvider{
        return _instance
    }
    
    let fbEventFetchFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        return formatter
    }()
    
    let fbDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    let fbUserFetchFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    func graphRequest(pageID: String, fetchParameters: String, FBHandler: @escaping FBSDKGraphRequestHandler) {
        FBSDKGraphRequest(graphPath: pageID, parameters: ["fields": fetchParameters]).start(completionHandler: FBHandler)
    }
    
    func fetchUserData(completion: @escaping () -> ()) {
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": FB_USER_FETCH_PARAMS]).start { (connection, result, error) in
            
            if error != nil {
                // graph request fail
                return
            }
            if let allResults = result as? [String: AnyObject] {
                let id = allResults["id"] as? String
                let name = allResults["name"] as? String
                var email = allResults["email"] as? String
                let gender = allResults["gender"] as? String
                var birthday = allResults["birthday"] as? String
                
                let birthdayComp: Date = self.fbUserFetchFormatter.date(from: birthday!)!
                let ageComponents = Calendar.current.dateComponents([.year], from: birthdayComp, to: Date())
                let age = ageComponents.year!
                
                DBProvider.Instance.saveUser(name: name!, birthday: &birthday, gender: gender!, email: &email, fbid: id!)
                FacebookUser.Instance.set(userName: name!, userAge: age, userGender: gender!, userID: id!)
                
                if email != nil {
                    Crashlytics.sharedInstance().setUserEmail(email)
                }
                Crashlytics.sharedInstance().setUserIdentifier(id)
                Crashlytics.sharedInstance().setUserName(name)
                
                completion()
            }
        }
    }
    
    
    func fetchEventData(pageID: String, completion: @escaping ([String: String]?) -> ()) {
        
        let dateTodayString = fbUserFetchFormatter.string(from: Date())
        let dateToday = fbUserFetchFormatter.date(from: dateTodayString)
        let timeInterval = dateToday?.timeIntervalSince1970
        
        FBSDKGraphRequest(graphPath: "\(pageID)/events", parameters: ["since": "\(timeInterval!)", "until": "\(timeInterval! + 86400)"]).start { (connection, result, error) in
            if error != nil {
                // error
                return
            }
            let allResults = result as! [String: AnyObject]
            let events = allResults["data"] as! [[String: AnyObject]]
            
            let currentDate = Constants.Instance.getDateInDBFormat()
            var eventData = [String: String]()
            
            for event in events {
                
                if let eventStart = event["start_time"] as? String {
                    
                    let eventDate = self.fbEventFetchFormatter.date(from: eventStart)
                    let eventDateString = DATE_FORMATTER_DB.string(from: eventDate!)
                    
                    if eventDateString == currentDate { // check if an event exists today
                        
                        let startTimeString = self.fbDisplayFormatter.string(from: eventDate!)
                        eventData.updateValue(startTimeString, forKey: FIR_EVENT_INFO.START_TIME)
                        
                        if let eventEndDate = event["end_time"] as? String {
                            if let eventEndDateString = self.fbEventFetchFormatter.date(from: (eventEndDate)) {
                                let endTimeString = self.fbDisplayFormatter.string(from: eventEndDateString)
                                eventData.updateValue(endTimeString, forKey: FIR_EVENT_INFO.END_TIME)
                            }
                        }
                        
                        if let place = event["place"] as? [String: AnyObject] {
                            if let locationName = place["name"] as? String {
                                eventData.updateValue(locationName, forKey: FIR_EVENT_INFO.LOCATION)
                            }
                        }
                        
                        if let description = event["description"] as? String {
                            eventData.updateValue(description, forKey: FIR_EVENT_INFO.DESCRIPTION)
                        }
                        
                        if let name = event["name"] as? String {
                            eventData.updateValue(name, forKey: FIR_EVENT_INFO.NAME)
                        }
                        
                        // check if already exists
                        DBProvider.Instance.saveEvent(pageId: pageID, eventData: eventData)
                        completion(eventData)
                        return
                    }
                    else {
                        completion(nil)
                        return
                    }
                }
                
            }
        }
    }
}






