//
//  EppykLabelView.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 23/01/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation
import UIKit

class EppykLabelView: UILabel {

    override func awakeFromNib() {
        let attributedString = NSMutableAttributedString(string: self.text!)
        attributedString.addAttribute(NSKernAttributeName, value: 3, range: NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }

}

