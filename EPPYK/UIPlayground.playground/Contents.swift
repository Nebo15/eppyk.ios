//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

// liveView
let screenWidth = 375
let screenHeight = 667
let containerView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
XCPlaygroundPage.currentPage.liveView = containerView

//MARK: Label
func createEppykLabel() {
    let label = UILabel(frame: CGRect(x:0, y:40, width:screenWidth, height:21))
    label.textColor = UIColor.whiteColor()
    label.text = "WHAT'S YOUR QUEATION?"
    label.textAlignment = .Center
    containerView .addSubview(label)

    let attributedString = NSMutableAttributedString(string: label.text!)
    attributedString.addAttribute(NSKernAttributeName, value: 1.8, range: NSMakeRange(0, attributedString.length))
    label.attributedText = attributedString
}

//MARK: Star
func generateStar() {
    let minStarSize: UInt32 = 15
    let maxStarSize: UInt32 = 45
    
    let starSize = CGFloat.init(arc4random_uniform(maxStarSize - minStarSize)+minStarSize)
    var starImage = UIImage.init(named: "star")!

//    if starSize < CGFloat.init(maxStarSize) - 5 {
//        starImage = starImage.resize(starSize)
//    }
    
    let image = UIImageView.init(image: starImage)
    var frame = image.frame
    frame.size.height = starSize
    frame.size.width = starSize
    image.frame = frame
    
}

extension UIImage {
    
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        self.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}



generateStar()
