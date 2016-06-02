//
//  StringExtension.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 28/01/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: "UI", bundle: NSBundle.mainBundle(), value: "", comment: "")
    }

    var localizedAnswer: String {
        return NSLocalizedString(self, tableName: "L10n", bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    
}