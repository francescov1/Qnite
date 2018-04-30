//
//  ActivityIndicator.swift
//  Qnight
//
//  Created by David Choi on 2017-06-25.
//  Copyright © 2017 David Choi. All rights reserved.
//

import Foundation

class ActivityIndicator {
    
    private static let _instance = NotificationProvider()
    static var Instance: NotificationProvider {
        return _instance
    }
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    func initActivityIndicator(view: UIView){
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray;
        activityIndicator.center = view.center;
    }
    
    
    
}
