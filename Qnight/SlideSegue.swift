//
//  SlideSegue.swift
//  Qnight
//
//  Created by David Choi on 2017-06-01.
//  Copyright © 2017 David Choi. All rights reserved.
//

import UIKit

class SlideSegue: UIStoryboardSegue{
    
    override func perform(){
        slide()
    }
    
    func slide(){
        let toViewController = self.destination
        let fromViewController = self.source
        
        let originalCenter = fromViewController.view.center
        
        toViewController.view.transform = CGAffineTransform(translationX: 100, y: 0.0)
        
        toViewController.view.center = originalCenter
        
        UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseInOut, animations: { toViewController.view.transform = CGAffineTransform.identity}, completion: {success in fromViewController.present(toViewController,animated:false,completion:nil)})
        
    }
    
    
    
    
}
