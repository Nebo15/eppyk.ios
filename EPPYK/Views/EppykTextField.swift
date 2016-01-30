//
//  EppykTextField.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 30/01/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation
import UIKit

class EppykTextField: UITextField {
    
    var bottomBorder: CALayer?
    
    override func awakeFromNib() {
        
        // Placeholder
        if let placeHolderText = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string:placeHolderText, attributes:[NSKernAttributeName: 3, NSForegroundColorAttributeName: UIColorFromRGB(0x94aecb) ])
        }
        
        // Bottom view
        self.updateBottomBorder()
    
    }
    
    func updateBottomBorder() {
        self.bottomBorder = CALayer.init()
        self.bottomBorder!.frame = CGRect.init(x: 0, y: self.frame.size.height-1, width: self.frame.size.width, height: 1)
        self.bottomBorder!.backgroundColor = UIColorFromRGB(0x94aecb).CGColor
        self.layer.addSublayer(self.bottomBorder!)
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        
        if let bottomBorder = self.bottomBorder {
            bottomBorder.removeFromSuperlayer()
        }
        self.updateBottomBorder()
        
    }
    
}