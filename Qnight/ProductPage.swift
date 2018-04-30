//
//  SpinningViewBrain.swift
//  Qnight
//
//  Created by David Choi on 2017-05-29.
//  Copyright © 2017 David Choi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ProductPage {
    
    var logoImageName: String
    var instagramHandle: String
    var facebookHandle: String
    var pageID: String
    var address: String
    var name: String
    var coordinates: [String: Double]
    
    
    init (logoImageName: String, instagramHandle: String, facebookHandle: String, pageID: String, address: String, name: String, coordinates: [String: Double]){
        
        self.name = name
        self.address = address
        self.coordinates = coordinates
        self.logoImageName = logoImageName
        self.instagramHandle = instagramHandle
        self.facebookHandle = facebookHandle
        self.pageID = pageID
    }
}




