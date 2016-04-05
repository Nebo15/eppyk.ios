//
//  AdminViewController.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 30/01/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation
import UIKit
import AFNetworking


class AdminViewController: RootViewController {

    @IBOutlet weak var statusLabelView: UILabel!
    
    @IBOutlet weak var answerTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var sourceString = "l10n"
        if QAManager.sharedInstance.getSource() == QAManager.QASource.DB {
            sourceString = "DB"
        }
        self.statusLabelView.text = "Status: \(sourceString)"
    }

    @IBAction func addAnswerClicked(sender: AnyObject) {
        if self.answerTextField.text!.isEmpty {
            return
        }
        
//        QAManager.sharedInstance.addAnswer(self.answerTextField.text!)
        self.answerTextField.text = ""
        
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
