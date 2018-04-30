//
//  LocationHandler.swift
//  Qnight
//
//  Created by Francesco Virga on 2017-06-22.
//  Copyright © 2017 David Choi. All rights reserved.
//
import Foundation
import CoreLocation
import FirebaseDatabase

class LocationProvider: NSObject, CLLocationManagerDelegate {
    private static let _instance = LocationProvider()
    static var Instance: LocationProvider {
        return _instance
    }
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        initializeRegionsToMonitor()
    }
    
    func initializeRegionsToMonitor() {
        DBProvider.Instance.venueInfoRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? [String: Any] {
                for (key, _) in data {
                    if let venue = data[key] as? [String: Any] {
                        if let coordinates = venue[FIR_VENUE_INFO.COORDINATES] as? [String: Any] {
                            _ = venue[FIR_VENUE_INFO.NAME] as! String
                            let lat = coordinates[FIR_VENUE_INFO.COORDINATES_LAT] as! Double
                            let long = coordinates[FIR_VENUE_INFO.COORDINATES_LONG] as! Double
                            let location = CLLocationCoordinate2DMake(lat, long)
                            
                            let pageId = key
                            
                            self.monitorRegionAtLocation(center: location, identifier: pageId)
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
        NotificationCenter.default.post(name: LISTENER_NAME.LOCATION, object: currentLocation)
    }
    
    func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String) {
        if getAuthStatus() {
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                
                let region = CLCircularRegion(center: center, radius: 10, identifier: identifier)
                region.notifyOnEntry = true
                region.notifyOnExit = true
                locationManager.startMonitoring(for: region)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            
            let currentHour = DATE_FORMATTER_HOUR.string(from: Date())
            if Int(currentHour)! > 20 {
                return // if its earleir than 8pm dont ask to buy cover
            }
            
            let identifier = region.identifier
            var didBuy = false
            var venueName: String?
            
            let group = DispatchGroup()
            group.enter()
            DBProvider.Instance.eventRef.child(identifier).child(Constants.Instance.getDateInDBFormat()).child(FIR_EVENT_DATA.USERS_ATTENDING).child(FacebookUser.Instance.id!).child(FIR_EVENT_DATA.COVER_ID).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                if snapshot.value != nil {
                    didBuy = true
                }
                group.leave()
            })
            
            group.enter()
            DBProvider.Instance.venueInfoRef.child(identifier).child(FIR_VENUE_INFO.NAME).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                if let name = snapshot.value as? String {
                    venueName = name
                }
                group.leave()
            })
            
            group.notify(queue: .main) {
                if !didBuy {
                    var title: String?
                    if venueName != nil {
                        title = "Heading to \(venueName ?? "") tonight?"
                    }
                    else {
                        title = "Heading out tonight?"
                    }
                    // only send notif if place has cover
                    NotificationProvider.Instance.activateTimedNotification(title: title!, body: "Pay for cover now to save time!", categoryID:  NOTIFICATION_ID.CATEGORY_ATTENDING_EVENT, requestID: identifier, time: 900) // send after 15 min
                }
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            NotificationProvider.Instance.checkPendingNotifications(idToCheck: identifier, completion: { (exists) in
                if exists {
                    NotificationProvider.Instance.removeLocalNotification(requestIDs: [identifier])
                }
            })
        }
    }
    
    func getAuthStatus() -> Bool {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            return true
        }
        else {
            return false
        }
    }
    
    func requestAuth() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
    }
}
