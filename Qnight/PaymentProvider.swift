//
//  PaymentProvider.swift
//  Qnight
//
//  Created by Francesco Virga on 2017-07-10.
//  Copyright © 2017 David Choi. All rights reserved.
//

import Foundation
import UIKit
import PassKit
import FirebaseDatabase
import Stripe

class PaymentProvider: NSObject, PKPaymentAuthorizationViewControllerDelegate {
    private static let _instance = PaymentProvider()
    static var Instance: PaymentProvider {
        return _instance
    }
    
    var paymentRequest: PKPaymentRequest!
    
    func payAction(viewController: UIViewController, pageId: String, pageName: String) {
        
        
        //let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: "com.merchant.your_application")\
        
        let paymentNetworks = [PKPaymentNetwork.amex, .visa, .masterCard, .discover, .interac]
        
        // can also check applePayButton.enabled = Stripe.deviceSupportsApplePay() (this returns a bool)
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks:
            paymentNetworks) {
            
            //let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: MERCHANT_ID)
            
            paymentRequest = PKPaymentRequest()
            paymentRequest.merchantIdentifier = MERCHANT_ID
            paymentRequest.currencyCode = "CAD"
            paymentRequest.countryCode = "CA"
            paymentRequest.supportedNetworks = paymentNetworks
            paymentRequest.merchantCapabilities = .capability3DS
            paymentRequest.requiredShippingAddressFields = [.name,.email]
            paymentRequest.paymentSummaryItems = self.itemToSell(venue: pageName)
            paymentRequest.applicationData = pageId.data(using: .utf8)
            
            let phoneShippingMethod = PKShippingMethod(label: "QR Code", amount: 0.00)
            phoneShippingMethod.detail = "Qnite will generate a QR Code to scan for proof of purchase. A receipt will be sent to your email."
            phoneShippingMethod.identifier = "QRCode"
            
            paymentRequest.shippingMethods = [phoneShippingMethod]
            
            if Stripe.canSubmitPaymentRequest(paymentRequest) {
                let applePayViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                applePayViewController.delegate = self
                
                viewController.present(applePayViewController, animated: true, completion: nil)
            }
            else {
                // There is a problem with your Apple Pay configuration
                alertUser(viewController: viewController, title: "problem with apple pay config", message: "sorry")
            }
            
        }
        else {
            alertUser(viewController: viewController, title: "Apple Pay not avaibale", message: "Ensure you have set up Apple Pay. Our system supports Visa, Mastercard, Discover, Interac and Amex credit cards.")
        }
    }
    
    // Sent to the delegate after the user has acted on the payment request.  The application
    // should inspect the payment to determine whether the payment request was authorized.
    //
    // If the application requested a shipping address then the full addresses is now part of the payment.
    //
    // The delegate must call completion with an appropriate authorization status, as may be determined
    // by submitting the payment credential to a processing gateway for payment authorization.
    
    @available(iOS 8.0, *)
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Swift.Void) {
        
        STPAPIClient.shared().createToken(with: payment) { (token, error) in
            
            let pageId = String(data: self.paymentRequest.applicationData!, encoding: .utf8)
            
            
            
            guard let token = token, error == nil else {
                print("Error from payment:\(error!.localizedDescription)")
                return
            }
            
            self.submitTokenToBackend(token: token, pageId: pageId!, completion: { (error: Error?) in
                if error != nil {
                    // Present error to user...
                    
                    // Notify payment authorization view controller
                    completion(.failure)
                }
                else {
                    // Save payment success
                    //paymentSucceeded = true
                    
                    // Notify payment authorization view controller
                    completion(.success)
                }
            })
        }
    }
    
    func submitTokenToBackend(token: STPToken, pageId: String, completion: (Error?) -> ()) {
        self.generateTransactionKeys(fbID: FacebookUser.Instance.id!, serialKey: nil, pageId: pageId)
        
        let idempotencyKey = randomSerial(length: 32)
        
        let chargeData: [String: Any] = ["source": token.tokenId, "amount": paymentRequest.paymentSummaryItems.last?.amount, "venue": pageId]
        DBProvider.Instance.dbRef.child("stripe_customers").child(FacebookUser.Instance.id!).child("charges").child(idempotencyKey).updateChildValues(chargeData)// last item should be total price
        
        // check that charge was made
        
        completion(nil)
    }
    
    
    
    
    // Sent to the delegate when payment authorization is finished.  This may occur when
    // the user cancels the request, or after the PKPaymentAuthorizationStatus parameter of the
    // paymentAuthorizationViewController:didAuthorizePayment:completion: has been shown to the user.
    //
    // The delegate is responsible for dismissing the view controller in this method.
    @available(iOS 8.0, *)
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        
        
        controller.dismiss(animated: true, completion: {
            /*if (self.paymentSucceeded) {
             // show a receipt page
             }*/
            NotificationCenter.default.post(name: LISTENER_NAME.PAYMENT_COVER, object: nil)
        })
        
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, completion: @escaping (PKPaymentAuthorizationStatus, [PKPaymentSummaryItem]) -> Void) {
        
        completion(PKPaymentAuthorizationStatus.success, itemToSell(venue: "ERROR"))
    }
    
    func itemToSell(venue: String) -> [PKPaymentSummaryItem] {
        let cover = PKPaymentSummaryItem(label: "Cover for \(venue) on \(Date())", amount: 3.99)
        let processing = PKPaymentSummaryItem(label: "Processing", amount: 1.00)
        let totalAmount = cover.amount.adding(processing.amount)
        let totalPrice = PKPaymentSummaryItem(label: venue, amount: totalAmount)
        
        return [cover, processing, totalPrice]
    }
    
    
    func generateQRCode(fbID: String, QRImageView: UIImageView, pageId: String, completion: @escaping (UIImage?) -> ()) {
        
        DBProvider.Instance.eventRef.child(pageId).child(Constants.Instance.getDateInDBFormat()).child(FIR_EVENT_DATA.USERS_ATTENDING).child(fbID).child(FIR_EVENT_DATA.COVER_ID).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if let serial = snapshot.value as? String {
                let QRstring = "\(fbID),\(serial)"
                
                let data = QRstring.data(using: String.Encoding.isoLatin1)
                if let filter = CIFilter(name: "CIQRCodeGenerator") {
                    filter.setValue(data, forKey: "inputMessage")
                    filter.setValue("H", forKey: "inputCorrectionLevel")
                    let qrCodeImage = filter.outputImage!
                    let scaleX = QRImageView.frame.size.width / qrCodeImage.extent.size.width
                    let scaleY = QRImageView.frame.size.height / qrCodeImage.extent.size.height
                    let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                    
                    if let output = filter.outputImage?.applying(transform) {
                        completion(UIImage(ciImage: output))
                    }
                }
                completion(nil)
            }
        }
    }
    
    func randomSerial(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    
    
    func alertUser(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(ok)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    
    func generateTransactionKeys(fbID: String, serialKey: String?, pageId: String) {
        var serialKey = serialKey
        if serialKey == nil {
            serialKey = randomSerial(length: 32) // need to ensure theres no copies
            DBProvider.Instance.eventRef.child(pageId).child(Constants.Instance.getDateInDBFormat()).child(FIR_EVENT_DATA.USERS_ATTENDING).child(fbID).child(FIR_EVENT_DATA.COVER_ID).setValue(serialKey!)
            DBProvider.Instance.eventRef.child(pageId).child(Constants.Instance.getDateInDBFormat()).child(FIR_EVENT_DATA.USERS_ATTENDING).child(fbID).child(FIR_EVENT_DATA.DID_SCAN).setValue(false)
            
        }
    }
    
    
    /*
     // Sent to the delegate before the payment is authorized, but after the user has authenticated using
     // passcode or Touch ID. Optional.
     @available(iOS 8.3, *)
     optional public func paymentAuthorizationViewControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationViewController) {
     
     }
     
     
     // Sent when the user has selected a new shipping method.  The delegate should determine
     // shipping costs based on the shipping method and either the shipping address supplied in the original
     // PKPaymentRequest or the address fragment provided by the last call to paymentAuthorizationViewController:
     // didSelectShippingAddress:completion:.
     //
     // The delegate must invoke the completion block with an updated array of PKPaymentSummaryItem objects.
     //
     // The delegate will receive no further callbacks except paymentAuthorizationViewControllerDidFinish:
     // until it has invoked the completion block.
     @available(iOS 8.0, *)
     optional public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, completion: @escaping (PKPaymentAuthorizationStatus, [PKPaymentSummaryItem]) -> Swift.Void) {
     
     }
     
     
     // Sent when the user has selected a new shipping address.  The delegate should inspect the
     // address and must invoke the completion block with an updated array of PKPaymentSummaryItem objects.
     //
     // The delegate will receive no further callbacks except paymentAuthorizationViewControllerDidFinish:
     // until it has invoked the completion block.
     @available(iOS, introduced: 8.0, deprecated: 9.0, message: "Use the CNContact backed delegate method instead")
     optional public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingAddress address: ABRecord, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Swift.Void) {
     
     }
     
     
     @available(iOS 9.0, *)
     optional public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Swift.Void) {
     
     }
     
     
     // Sent when the user has selected a new payment card.  Use this delegate callback if you need to
     // update the summary items in response to the card type changing (for example, applying credit card surcharges)
     //
     // The delegate will receive no further callbacks except paymentAuthorizationViewControllerDidFinish:
     // until it has invoked the completion block.
     @available(iOS 9.0, *)
     optional public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect paymentMethod: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Swift.Void) {
     
     }
     */
    
}
