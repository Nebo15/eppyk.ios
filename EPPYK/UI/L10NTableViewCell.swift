//
//  L10NTableViewCell.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 19/02/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import UIKit

class L10NTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moviesLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    var l10n: L10n?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func setL10N(l10n: L10n) {
        self.l10n = l10n
        self.titleLabel.textColor = UIColor.whiteColor()
        
        self.titleLabel.text = l10n.title
        
        self.moviesLabel.textColor = UIColor.whiteColor()
        self.moviesLabel.text = l10n.description
        
    }
    
}
