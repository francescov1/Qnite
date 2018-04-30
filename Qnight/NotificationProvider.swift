//
//  NotificationProvider.swift
//  Qnight
//
//  Created by Francesco Virga on 2017-06-19.
//  Copyright © 2017 David Choi. All rights reserved.
//
import Foundation
import UserNotifications

class NotificationProvider: NSObject, UNUserNotificationCenterDelegate {
    private static let _instance = NotificationProvider()
    static var Instance: NotificationProvider {
        return _instance
    }
    
    var notificationCenter: UNUserNotificationCenter {
        return UNUserNotificationCenter.current()
    }
    
    func handleNotificationResponse(center: UNUserNotificationCenter, response: UNNotificationResponse, completionHandler: @escaping () -> Swift.Void) {
        
        switch response.notification.request.content.categoryIdentifier {
            
        case NOTIFICATION_ID.CATEGORY_POST_EVENT:
            handlePostEventNotif(response: response)
            break
            
        case NOTIFICATION_ID.CATEGORY_ATTENDING_EVENT:
            handleAttendingEventNotif(response: response)
            break
            
        default:
            
            break
        }
    }
    
    func handleAttendingEventNotif(response: UNNotificationResponse) {
        switch response.actionIdentifier {
        case NOTIFICATION_ID.ACTION_BUY_COVER, UNNotificationDefaultActionIdentifier:
            
            // navigate to proper page
            // pop up apple pay
            break
            
        case NOTIFICATION_ID.ACTION_NOT_GOING:
            // check if user said going, if so, change to not going
            
            
            break
            
        default:
            
            break
        }
        // update FIR values
    }
    
    
    func handlePostEventNotif(response: UNNotificationResponse) {
        
        let pageID = response.notification.request.identifier
        let feedback: String
        
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            postEventAlert(title: response.notification.request.content.title, message:  response.notification.request.content.body, completion: { (response) in
                DBProvider.Instance.eventRef.child(pageID).child(Constants.Instance.getDateInDBFormat()).child(FIR_EVENT_DATA.USERS_ATTENDING).child(FacebookUser.Instance.id!).child(FIR_EVENT_DATA.FEEDBACK).setValue(response)
            })
            return
        }
        
        switch response.actionIdentifier {
            
        case  NOTIFICATION_ID.ACTION_GOOD:
            feedback = "Good"
            break
            
        case  NOTIFICATION_ID.ACTION_BAD:
            feedback = "Bad"
            break
            
        case  NOTIFICATION_ID.ACTION_NO_ATTENDANCE:
            feedback = "No Attendance"
            break
            
        default:
            feedback = "NA"
            break
        }
        
        let today = Constants.Instance.getDateInDBFormat()
        let index = today.index(today.endIndex, offsetBy: -2)
        let dayNum = Int(today.substring(from: index))
        let dateYesterday = today.substring(to: index) + "\(dayNum!-1)"
        
        DBProvider.Instance.eventRef.child(pageID).child(dateYesterday).child(FIR_EVENT_DATA.USERS_ATTENDING).child(FacebookUser.Instance.id!).child(FIR_EVENT_DATA.FEEDBACK).setValue(feedback)
    }
    
    func postEventAlert(title: String, message: String, completion: @escaping (String) -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let good = UIAlertAction(title: NOTIFICATION_TEXT.POST_EVENT_GOOD, style: .default) { (action) in
            completion("Good")
        }
        let bad = UIAlertAction(title: NOTIFICATION_TEXT.POST_EVENT_BAD, style: .default) { (action) in
            completion("Bad")
        }
        
        let noAttendance = UIAlertAction(title: NOTIFICATION_TEXT.POST_EVENT_NO_ATTENDANCE, style: .default) { (action) in
            completion("No Attendance")
        }
        
        alert.addAction(good)
        alert.addAction(bad)
        alert.addAction(noAttendance)
        
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        completionHandler(.alert)
    }
    
    
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        self.handleNotificationResponse(center: center, response: response, completionHandler: completionHandler)
    }
    
    func getAuthStatus(handler: @escaping (_ isAuth:Bool?) -> Void) {
        notificationCenter.getNotificationSettings() { (settings) in
            
            switch settings.authorizationStatus {
                
            case .authorized:
                handler(true)
                
            case .denied:
                handler(false)
                
            default:
                break
            }
        }
    }
    
    
    func activateCalendarNotification(title: String, body: String, categoryID: String, requestID: String, minute: Int, hour: Int, day: Int?) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        content.categoryIdentifier = categoryID
        var dateInfo = DateComponents()
        
        if day != nil {
            dateInfo.day = day
        }
        
        dateInfo.hour = hour
        dateInfo.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
        self.notificationCenter.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    func activateTimedNotification(title: String, body: String, categoryID: String, requestID: String, time: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        content.categoryIdentifier = categoryID
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
        self.notificationCenter.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
        
    }
    
    func sendInstantNotification(title: String, body: String, categoryID: String, requestID: String) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        content.categoryIdentifier = categoryID
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
        self.notificationCenter.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    func removeLocalNotification(requestIDs: [String]) {
        self.notificationCenter.removePendingNotificationRequests(withIdentifiers: requestIDs)
    }
    
    func initializeNotifications(application: UIApplication) {
        self.notificationCenter.delegate = self
        
        
        let generalCategory = UNNotificationCategory(identifier: "GENERAL", actions: [], intentIdentifiers: [], options: .customDismissAction)
        // Create the custom actions
        let goodAction = UNNotificationAction(identifier: NOTIFICATION_ID.ACTION_GOOD, title: NOTIFICATION_TEXT.POST_EVENT_GOOD, options: UNNotificationActionOptions(rawValue: 0))
        let badAction = UNNotificationAction(identifier:  NOTIFICATION_ID.ACTION_BAD, title: NOTIFICATION_TEXT.POST_EVENT_BAD, options: UNNotificationActionOptions(rawValue: 0))
        let noAttendanceAction = UNNotificationAction(identifier:  NOTIFICATION_ID.ACTION_NO_ATTENDANCE, title: NOTIFICATION_TEXT.POST_EVENT_NO_ATTENDANCE,  options: UNNotificationActionOptions(rawValue: 0))
        let postEventCategory = UNNotificationCategory(identifier:  NOTIFICATION_ID.CATEGORY_POST_EVENT, actions: [goodAction, badAction, noAttendanceAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        
        let buyCoverAction = UNNotificationAction(identifier:  NOTIFICATION_ID.ACTION_BUY_COVER, title: NOTIFICATION_TEXT.ATTENDING_EVENT_BUY_COVER, options: .foreground)
        let notGoingAction = UNNotificationAction(identifier:  NOTIFICATION_ID.ACTION_NOT_GOING, title: NOTIFICATION_TEXT.ATTENDING_EVENT_NOT_GOING, options: UNNotificationActionOptions(rawValue: 0))
        
        
        let attendingEventCategory = UNNotificationCategory(identifier:  NOTIFICATION_ID.CATEGORY_ATTENDING_EVENT, actions: [buyCoverAction, notGoingAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        
        // Register the notification categories.
        notificationCenter.setNotificationCategories([generalCategory, postEventCategory, attendingEventCategory])
        application.registerForRemoteNotifications()
        
    }
    
    func requestAuth() {
        let application = UIApplication.shared
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
            if error != nil {
                // error occured
            }
            if granted {
                application.registerForRemoteNotifications()
            }
            else {
                // user did not allow notifications, set this in FIR
            }
        })
    }
    
    func checkPendingNotifications(idToCheck: String, completion: @escaping (Bool) -> ()){
        notificationCenter.getPendingNotificationRequests { (requests) in
            for request in requests {
                if request.identifier == idToCheck {
                    completion(true)
                }
            }
            completion(false)
        }
    }
}
