//
//  StarView.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 22/01/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

enum GlowChance: UInt32 {
    case VeryBig=5, Big=10, Medium=15, Small=20, VerySmall=30
}

class Star: UIView {
    
    private let minStarSize: UInt32 = 15
    private let maxStarSize: UInt32 = 45
    private var glowChance: GlowChance = .Medium
    
    private var image: UIImageView?
    private let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRect.null)
        let starImage = UIImage.init(named: "star")!.resize(CGFloat.init(arc4random_uniform(maxStarSize - minStarSize)+minStarSize))
        self.image = UIImageView.init(image: starImage)
        
        let randPoint = CGPoint.init(x: Int(arc4random_uniform(UInt32.init(screenSize.width - starImage.size.width))),
            y: Int(arc4random_uniform(UInt32.init(screenSize.height/2))))
        
        
        let padding = CGFloat.init(2)
        
        self.frame = CGRect(x: randPoint.x, y: randPoint.y, width: starImage.size.width + padding * 2, height: starImage.size.height + padding * 2)
        
        self.image?.center = self.convertPoint((self.image?.center)!, fromView: self)
        self.addSubview(self.image!)
        
    }

    func startGlowing(chance: GlowChance) {
        self.glowChance = chance
        let time = Double.init(arc4random_uniform(5)) + 3.0 + drand48()
        NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: "glow", userInfo: nil, repeats: true)
    }
    
    func glow() {
        let chance = arc4random_uniform(self.glowChance.rawValue)
        if chance != 0 {
            return
        }
        
        let duration = 1.0
        
        // Set the image's shadowColor, radius, offset, and
        // set masks to bounds to false
        self.image!.layer.shadowColor = UIColor.yellowColor().CGColor
        self.image!.layer.shadowRadius = 10.0
        self.image!.layer.shadowOpacity = 0
        self.image!.layer.shadowOffset = CGSizeZero
        self.image!.layer.masksToBounds = false

        let delay = duration * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

        dispatch_after(time, dispatch_get_main_queue(), {
            // Animate the shadow opacity to "fade it out"
            let shadowAnimOut = CABasicAnimation()
            shadowAnimOut.keyPath = "shadowOpacity"
            shadowAnimOut.fromValue = NSNumber(float: 1.0)
            shadowAnimOut.toValue = NSNumber(float: 0.0)
            shadowAnimOut.duration = duration
            self.image!.layer.addAnimation(shadowAnimOut, forKey: "shadowOpacity")
        })
    }
    
}