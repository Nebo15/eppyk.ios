//
//  Global.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 30/01/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation
import UIKit


let ScreenSize = UIScreen.mainScreen().bounds.size

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
