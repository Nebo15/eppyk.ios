//
//  StartViewController.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 18/02/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation


class StartViewController: RootViewController, L10nViewProtocol {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let _ = SettingsManager.sharedInstance.getValue(SettingsManager.SelectedL10N) else {
            UpdateManager.sharedInstance.updateL10ns({ (result, l10ns) -> Void in
                if result {
                    self.showL10NView(l10ns)
                } else {
                    self.goMain()
                }
            })
            return
        }
        self.goMain()
    }
    
    func showL10NView(data: [L10n]) {
        if let view = UIView.loadFromNibNamed("L10nView") {
            let frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y,
                                   self.view.bounds.size.width, self.view.bounds.size.height + L10nView.UpBounse)
            view.frame = frame
            (view as! L10nView).delegate = self
            (view as! L10nView).data = data
            self.view.addSubview(view)
            (view as! L10nView).show()
        }
        
    }
    
    func goMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let paymentViewController = storyboard.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
        self.navigationController?.pushViewController(paymentViewController, animated: false)
    }
    
    ///MARK: L10nViewProtocol
    func didSelectL10N(l10n: String) {
        
        
    }
    
    func didFinishWithL10N(l10n: String) {
        self.goMain()
    }


}