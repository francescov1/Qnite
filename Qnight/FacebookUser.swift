//
//  FacebookUser.swift
//  Qnight
//
//  Created by Francesco Virga on 2017-06-07.
//  Copyright © 2017 David Choi. All rights reserved.
//

import Foundation

class FacebookUser {
    private static let _instance = FacebookUser()
    static var Instance: FacebookUser {
        return _instance
    }
    
    var name: String?
    var age: Int?
    var gender: String?
    var id: String?
 
    func set(userName: String, userAge: Int, userGender: String, userID: String) {
        self.name = userName
        self.age = userAge
        self.gender = userGender
        self.id = userID
    }
}
