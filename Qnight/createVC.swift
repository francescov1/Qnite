//
//  createVC.swift
//  Qnight
//
//  Created by David Choi on 2017-06-14.
//  Copyright © 2017 David Choi. All rights reserved.
//

import Foundation

class createVC {
    private static let _instance = createVC()
    static var Instance: createVC{
        return _instance
    }
    
    func createViewController(productPage: ProductPage?) -> UIViewController {
        let vc = ProductContainerViewController()
        vc.productPage = productPage
        let title: String = (productPage?.name)!
        vc.title = "\(title)"
        return vc
    }
    
}
