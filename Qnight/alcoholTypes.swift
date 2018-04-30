//
//  alcoholTypes.swift
//  Qnight
//
//  Created by David Choi on 2017-07-11.
//  Copyright © 2017 David Choi. All rights reserved.
//

import Foundation

class alcoholTypes{
    private static let _instance = alcoholTypes()
    static var Instance: alcoholTypes{
        return _instance
    }

    func alcoholTypeImages(type: String)->[UIImage]{
        switch (type){
            case "beer":
                return beer
            case "bar":
                return bar
            case "bottle":
                return bottle
            case "tap":
                return tap
            default:
                print("error")
        }
        return beer
    }
    
    var beer: [UIImage] = [
        #imageLiteral(resourceName: "alexanderKeith"),
        #imageLiteral(resourceName: "budLight"),
        #imageLiteral(resourceName: "budweiser"),
        #imageLiteral(resourceName: "coorsLight"),
        #imageLiteral(resourceName: "corona"),
        #imageLiteral(resourceName: "heineken"),
        #imageLiteral(resourceName: "molsonCanadian"),
        #imageLiteral(resourceName: "smirnoffIce"),
        #imageLiteral(resourceName: "somersby"),
        #imageLiteral(resourceName: "strongbow"),
        #imageLiteral(resourceName: "twistedTea")
    ]
    
    var bottle: [UIImage] = [
        #imageLiteral(resourceName: "alexanderKeith"),
        #imageLiteral(resourceName: "budLight"),
        #imageLiteral(resourceName: "budweiser"),
        #imageLiteral(resourceName: "coorsLight"),
        #imageLiteral(resourceName: "corona"),
        #imageLiteral(resourceName: "heineken"),
        #imageLiteral(resourceName: "molsonCanadian"),
        #imageLiteral(resourceName: "smirnoffIce"),
        #imageLiteral(resourceName: "somersby"),
        #imageLiteral(resourceName: "strongbow"),
        #imageLiteral(resourceName: "twistedTea")
    ]
    
    var bar: [UIImage] = [
        #imageLiteral(resourceName: "alexanderKeith"),
        #imageLiteral(resourceName: "budLight"),
        #imageLiteral(resourceName: "budweiser"),
        #imageLiteral(resourceName: "coorsLight"),
        #imageLiteral(resourceName: "corona"),
        #imageLiteral(resourceName: "heineken"),
        #imageLiteral(resourceName: "molsonCanadian"),
        #imageLiteral(resourceName: "smirnoffIce"),
        #imageLiteral(resourceName: "somersby"),
        #imageLiteral(resourceName: "strongbow"),
        #imageLiteral(resourceName: "twistedTea")
    ]
    
    var tap: [UIImage] = [
        #imageLiteral(resourceName: "alexanderKeithLogo"),
        #imageLiteral(resourceName: "budLightLogo"),
        #imageLiteral(resourceName: "budweiserLogo"),
        #imageLiteral(resourceName: "coorsLightLogo"),
        #imageLiteral(resourceName: "coronaLogo"),
        #imageLiteral(resourceName: "heinekenLogo"),
        #imageLiteral(resourceName: "molsonCanadianLogo"),
        #imageLiteral(resourceName: "somersbyLogo"),
        #imageLiteral(resourceName: "strongbowLogo"),
        #imageLiteral(resourceName: "twistedTeaLogo")
    ]
    
    
}
