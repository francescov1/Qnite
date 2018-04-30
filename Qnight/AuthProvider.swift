//
//  AuthProvider.swift
//  Qnight
//
//  Created by Francesco Virga on 2017-06-12.
//  Copyright © 2017 David Choi. All rights reserved.
//
import Foundation
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import Crashlytics

typealias LoginHandler = (_ msg: String?) -> Void

class AuthProvider {
    private static let _instance = AuthProvider()
    static var Instance: AuthProvider {
        return _instance
    }
    
    
    let fetchFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    func login(loginHandler: LoginHandler?) { // need to handle when user declines permissions
        let accessToken =  FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {
            loginHandler?("You need to login to Facebook to use Qnite")
            return
        }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
            }
            else {
                FBProvider.Instance.fetchUserData {
                    initProductPages.Instance.loadData()
                    loginHandler?(nil)
                }
            }
        })
    }
        
    func logout() -> Bool {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                return true
            }
            catch {
                return false
            }
        }
        return true
    }
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?) {
        /*if let error = FIRAuthErrorCode(rawValue: err.code) { // converting error into a
         //firebase error to know what is wrong
         // handle errors with FIR Sign in
         }*/
    }
    
    
    
}
