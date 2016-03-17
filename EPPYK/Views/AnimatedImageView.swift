//
//  AnimatedImageView.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 02/03/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation

class AnimatedImageView: UIImageView {
    
    var animation: CAKeyframeAnimation? = nil
    var images: [CGImage]?
    var animationImageCount: UInt = 0
    weak var animationDelegate: AnyObject?
    private(set) var animationTime: CFTimeInterval = 0
    
    override func awakeFromNib() {

    }
    
    func loadAnimation(prefix: String, sufix: String, startIndex: UInt, endIndex: UInt) {
        self.images = [CGImage]()
        self.animationImageCount = endIndex - startIndex

        
        for index in startIndex...endIndex {
            let sourcePath = NSBundle.mainBundle().pathForResource(String(format: "%@%05d%@", prefix, index, sufix), ofType: "png")
            let _img = UIImage.init(contentsOfFile: sourcePath!)
            guard let img = _img else {
                assertionFailure(String(format: "%@%05d is nil", prefix, index))
                return;
            }
            self.images!.append( img.CGImage! )
            print(String(format: "%@%05d loaded", prefix, index))
        }
        
        self.animation = CAKeyframeAnimation.init(keyPath: "contents")
        self.animation!.calculationMode = kCAAnimationLinear;
        self.animation!.fillMode = kCAFillModeBoth;
        self.animationTime = Double.init(animationImageCount) / 25.0
        self.animation!.duration = self.animationTime;
        self.animation!.values = self.images;
        self.animation!.repeatCount = 1
        self.animation!.delegate = self
        self.animation!.removedOnCompletion = false;
    }
    
    func removeAnimation() {
        
        guard let animation = self.animation else {
            return;
        }
        self.layer.removeAnimationForKey("animation");
        self.animation = nil
        self.images!.removeAll()        
        self.images = nil
    }
    
    func runAnimation() {
        self.layer.addAnimation(self.animation!, forKey: "animation")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let image = images!.last {
            self.image = UIImage(CGImage: image)
        }
        self.removeAnimation()
        guard let delegate = self.animationDelegate else {
            return
        }
        delegate.animationDidStop(anim, finished: flag)
    }
    
    override func animationDidStart(anim: CAAnimation) {
        
        guard let delegate = self.animationDelegate else {
            return
        }
        delegate.animationDidStart(anim)
    }
    
    
    deinit {
        print("Deinit animation")
    }

    
    
}