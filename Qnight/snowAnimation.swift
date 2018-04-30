//
//  snowAnimation.swift
//  Qnight
//
//  Created by David Choi on 2017-06-14.
//  Copyright © 2017 David Choi. All rights reserved.
//

import Foundation

class snowAnimation {
    private static let _instance = snowAnimation()
    static var Instance: snowAnimation{
        return _instance
    }
    
    func snowBlur(with image: UIImage, view: UIView){
        let emitter = Emitter.get(with: image)
        emitter.emitterPosition = CGPoint(x: view.frame.width / 2, y: 0)
        emitter.emitterSize = CGSize(width: view.frame.width, height: 2)
        view.layer.addSublayer(emitter)
    }
}
