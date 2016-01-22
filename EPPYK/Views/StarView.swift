//
//  StarView.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 22/01/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation
import UIKit

class Star: UIView {
    
    let minStarSize: UInt32 = 15
    let maxStarSize: UInt32 = 45
    
    var image: UIImageView?
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
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

    func animateTransform(transform: CGAffineTransform) {
        let random = Double.init(Int(arc4random_uniform(2))) + drand48() + 1
        UIView.animateWithDuration(random, animations: { () -> Void in
            self.transform = transform
        })
    }
    
    
}