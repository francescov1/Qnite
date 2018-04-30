//
//  UberProvider.swift
//  Qnight
//
//  Created by Francesco Virga on 2017-07-22.
//  Copyright © 2017 David Choi. All rights reserved.
//

import Foundation
import UberRides
import CoreLocation

class UberProvider: RideRequestButtonDelegate {
    private static let _instance = UberProvider()
    static var Instance: UberProvider {
        return _instance
    }
    
    let ridesClient = RidesClient()
    let uberButton = RideRequestButton()
    
    
    func initUberButton() {
        let viewForUber = UIApplication.topViewController()?.view
        
        uberButton.translatesAutoresizingMaskIntoConstraints = false
        uberButton.clipsToBounds = true
        
        viewForUber?.addSubview(uberButton)
        
    }
    
    func updateButton(pickupLocation: CLLocation, dropoffLocation: CLLocation, dropoffName: String) {
        
        let builder = RideParametersBuilder().setPickupLocation(pickupLocation).setDropoffLocation(dropoffLocation, nickname: dropoffName)
        
        ridesClient.fetchCheapestProduct(pickupLocation: pickupLocation, completion: { product, response in
            if let productID = product?.productID {
                _ = builder.setProductID(productID)
                self.uberButton.rideParameters = builder.build()
                self.uberButton.loadRideInformation()
            }
        })
        
    }
    

    public func rideRequestButtonDidLoadRideInformation(_ button: RideRequestButton) {
        button.sizeToFit()
    }
    
    public func rideRequestButton(_ button: RideRequestButton, didReceiveError error: RidesError) {
        // error handling
    }
    
    
}
