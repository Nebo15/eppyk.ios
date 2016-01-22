//: Playground - noun: a place where people can play

import UIKit
import XCPlayground


// liveView
let screenWidth = 375
let screenHeight = 667
let containerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
XCPlaygroundPage.currentPage.liveView = containerView


func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}


class Star: UIView {
    
    var image: UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRect.null)
        let starImage = resizeImage(UIImage.init(named: "star")!, newWidth: CGFloat.init(arc4random_uniform(30)+15))
        self.image = UIImageView.init(image: starImage)
        
        let randPoint = CGPoint.init(x: Int(arc4random_uniform(UInt32.init(screenWidth))),
                                     y: Int(arc4random_uniform(UInt32.init(screenHeight/2))))
        
        self.frame = CGRect(x: randPoint.x, y: randPoint.y, width: starImage.size.width, height: starImage.size.height)
        
        self.image?.center = self.convertPoint((self.image?.center)!, fromView: self)
        self.addSubview(self.image!)
        
//        let startingColor = UIColor(red: (23.0/255.0), green: (159.0/255.0), blue: (47.0/255.0), alpha: 1.0)
//        self.backgroundColor = startingColor
        
    }
    
    func animateTransform(transform: CGAffineTransform) {
        let random = Double.init(Int(arc4random_uniform(2))) + drand48() + 1
        UIView.animateWithDuration(random, animations: { () -> Void in
            self.transform = transform
        })
    }
    
    
}
let f: Int64 = Int64((1.0 + drand48())) * Int64(NSEC_PER_SEC)
let r = 2 * NSEC_PER_SEC

/*************
* START HERE *
*************/

var stars = [Star]()
var fixedStars = [Star]()

for index in 0 ... 20 {
    let star = Star()
    stars.append(star)
    containerView.addSubview(star);
    if index < 10 {
        fixedStars.append(star)
    }
    
    star.animateTransform(CGAffineTransformMakeScale(1.3, 1.3))
}


var animator: UIDynamicAnimator!
var gravity: UIGravityBehavior!
var collision: UICollisionBehavior!

animator = UIDynamicAnimator(referenceView: containerView)
gravity = UIGravityBehavior(items: stars)
gravity.magnitude = 0.8
animator.addBehavior(gravity)


collision = UICollisionBehavior(items: fixedStars)
collision.translatesReferenceBoundsIntoBoundary = true
animator.addBehavior(collision)




