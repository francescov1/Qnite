//
//  DBProvider.swift
//  Qnight
//
//  Created by Francesco Virga on 2017-06-12.
//  Copyright © 2017 David Choi. All rights reserved.
//
import Foundation
import FirebaseDatabase

class DBProvider {
    private static let _instance = DBProvider()
    static var Instance: DBProvider{
        return _instance
    }
    
    var dbRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var usersRef: DatabaseReference {
        return dbRef.child("users")
    }
    
    var eventRef: DatabaseReference {
        return dbRef.child("event_stats")
    }
    
    var venueInfoRef: DatabaseReference {
        return dbRef.child("venue_info")
    }
    
    func saveUser(name: String, birthday: inout String?, gender: String, email: inout String?, fbid: String) {
        let data: [String: Any] = ["name": name, "birthday": birthday ?? "NA", "gender": gender, "email": email ?? "NA"]
        usersRef.child(fbid).updateChildValues(data)
    }
    
    func saveEvent(pageId: String, eventData: [String: String]) {
        self.eventRef.child(pageId).child(Constants.Instance.getDateInDBFormat()).child(FIR_EVENT_INFO.EVENT).updateChildValues(eventData)
    }
}
