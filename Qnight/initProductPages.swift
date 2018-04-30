//
//  initProductPage.swift
//  Qnight
//
//  Created by David Choi on 2017-06-14.
//  Copyright © 2017 David Choi. All rights reserved.
//

import Foundation
import FirebaseDatabase

class initProductPages {
    private static let _instance = initProductPages()
    static var Instance: initProductPages{
        return _instance
    }
    
    func loadData() {
        DBProvider.Instance.venueInfoRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? [String: Any] {
                for (key,value) in data {
                    if let pageData = value as? [String: Any] {
                        
                        var name = ""
                        var fbHandle = ""
                        var instaHandle = ""
                        var address = ""
                        var logoName = ""
                        var coordinates = [String: Double]()
                        var isDowntown: Bool?
                        
                        if pageData[FIR_VENUE_INFO.NAME] != nil {
                            name = pageData[FIR_VENUE_INFO.NAME] as! String
                        }
                        if pageData["fb_handle"] != nil {
                            fbHandle = pageData["fb_handle"] as! String
                        }
                        if pageData["insta_handle"] != nil {
                            instaHandle = pageData["insta_handle"] as! String
                        }
                        if pageData[FIR_VENUE_INFO.ADDRESS] != nil {
                            address = pageData[FIR_VENUE_INFO.ADDRESS] as! String
                        }

                        if pageData["logo_img_name"] != nil {
                            logoName = pageData["logo_img_name"] as! String
                        }
                        if pageData["downtown"] != nil {
                            isDowntown = pageData["downtown"] as? Bool
                        }
                        if pageData[FIR_VENUE_INFO.COORDINATES] != nil {
                            coordinates = pageData[FIR_VENUE_INFO.COORDINATES] as! [String: Double]
                        }
                        
                        let pageId = key
                        let productPage = ProductPage(logoImageName: logoName, instagramHandle: instaHandle, facebookHandle: fbHandle, pageID: pageId, address: address, name: name, coordinates: coordinates)
                        
                        if isDowntown! {
                            self.downtownProductPages.append(productPage)
                            self.downtownImages.append(UIImage(named: logoName)!)
                        }
                        else {
                            self.queensProductPages.append(productPage)
                            self.queensImages.append(UIImage(named: logoName)!)
                        }
                        
                    }
                }
                NotificationCenter.default.post(name: LISTENER_NAME.PAGE_LOADING_COMPLETE, object: nil)
            }
        }
    }
    
    var downtownProductPages = [ProductPage]()
    var queensProductPages = [ProductPage]()
    var downtownImages = [UIImage]()
    var queensImages = [UIImage]() // need to check if theres no image

    /*
    var downtownImages: [UIImage] = [
        UIImage(named: "AleHouse")!,
        UIImage(named: "AleHouse")!,
        UIImage(named: "Stages")!,
        UIImage(named: "Brooklyn")!,
        UIImage(named: "Stone City")!,
        UIImage(named: "Trinity")!]
    
    var queensImages: [UIImage] = [
        UIImage(named: "Clark")!,
        UIImage(named: "QP")!,
        UIImage(named: "Underground")!]
    */
    
}
