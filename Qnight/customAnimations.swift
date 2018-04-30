//
//  customAnimations.swift
//  Qnight
//
//  Created by David Choi on 2017-06-30.
//  Copyright © 2017 David Choi. All rights reserved.
//

import Foundation

class customAnimations{
    private static let _instance = customAnimations()
    static var Instance: customAnimations{
        return _instance
    }
    
    func fadeIn(view : UIView, delay: TimeInterval) {
        
        let animationDuration = 0.25
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.alpha = 0
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseInOut, animations: { () -> Void in
                view.alpha = 1
            }, completion: nil)
        }
    }

    func fadeViewInThenOut(view : UIView, delay: TimeInterval) {
        
        let animationDuration = 0.25
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.alpha = 1
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseInOut, animations: { () -> Void in
                view.alpha = 0
            },
                           completion: nil)
        }
    }
    
    func applyMotionEffect (toView view: UIView, magnitudex:Float, magnitudey: Float){
        let xMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = -magnitudex
        xMotion.maximumRelativeValue = magnitudex
        let yMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongHorizontalAxis)
        yMotion.minimumRelativeValue = -magnitudey
        yMotion.maximumRelativeValue = magnitudey
        let group = UIMotionEffectGroup()
        group.motionEffects = [xMotion, yMotion]
        view.addMotionEffect(group)
    }
}
