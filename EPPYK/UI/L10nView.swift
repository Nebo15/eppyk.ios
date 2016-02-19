//
//  L10nView.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 19/02/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation

protocol L10nViewProtocol {
    func didSelectL10N(l10n: String)
    func didFinishWithL10N(l10n: String)
}

class L10nView: UIView, UITableViewDataSource, UITableViewDelegate {
 
    static let UpBounse: CGFloat = 40
    
    var delegate: L10nViewProtocol?
    var data: [L10n] = []
    
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!

    override func awakeFromNib() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)        
        tableView.registerNib(UINib(nibName: "L10NTableViewCell", bundle: nil), forCellReuseIdentifier: "L10NTableViewCell")
        self.alpha = 0
    }
    
    func show() {
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                self.alpha = 0.9
            }, completion: nil)
    }
    
    @IBAction func doneClicked(sender: AnyObject) {
        var frame = self.frame
        frame.origin.y -= L10nView.UpBounse
        UIView.animateWithDuration(0.2, delay: 0.2, options: .CurveEaseOut, animations: { () -> Void in
            self.frame = frame
            }) { (Bool) -> Void in
                frame.origin.y = ScreenSize.height
                UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                    self.frame = frame
                    }) { (Bool) -> Void in
                        self.removeFromSuperview()
                        if let delegate = self.delegate {
                            delegate.didFinishWithL10N("")
                        }
                }
        }
        
    }
    
    ///MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let l10n = self.data[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("L10NTableViewCell", forIndexPath: indexPath) as! L10NTableViewCell
        
        cell.setL10N(l10n)
        
        return cell
    }
    
}