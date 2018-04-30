//
//  QRViewController.swift
//  Qnight
//
//  Created by David Choi on 2017-07-21.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit

class QRViewController: UIViewController {

    @IBOutlet weak var qrImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        PaymentProvider.Instance.generateQRCode(fbID: FacebookUser.Instance.id!, QRImageView: qrImageView, pageId: , completion: { (image) in
//            
//            if image != nil {
//                self.qrImageView.image = image!
//            }
//            
//        })

        // Do any additional setup after loading the view.
    }


    @IBAction func viewWasTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }


}
