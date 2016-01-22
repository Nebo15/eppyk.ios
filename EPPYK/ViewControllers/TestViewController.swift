//
//  TestViewController.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 22/01/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    //MARK: Vars
    
    @IBOutlet weak var startButtonView: UIButton!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var animationImageView: UIImageView!
    @IBOutlet weak var animationDurationSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: Actions
    
    var animatedImage = UIImage.animatedImageNamed("test", duration: 3.0)
    @IBAction func startButtonClicked(sender: AnyObject) {
        
        animationImageView.animationImages = animatedImage?.images
        animationImageView.animationRepeatCount = 1
        animationImageView.startAnimating()
        
        startButtonView.setTitle("Stop", forState: .Normal)
        startButtonView.removeTarget(self, action: "startButtonClicked:", forControlEvents: .TouchUpInside)
        startButtonView.addTarget(self, action: "stopButtonClicked:", forControlEvents: .TouchUpInside)
        
    }
    
    func stopButtonClicked(sender: AnyObject) {
        
        animationImageView.stopAnimating()
        
        startButtonView.setTitle("Start", forState: .Normal)
        startButtonView.removeTarget(self, action: Selector("stopButtonClicked:"), forControlEvents: .TouchUpInside)
        startButtonView.addTarget(self, action: Selector("startButtonClicked:"), forControlEvents: .TouchUpInside)
        
    }
    
    @IBAction func animationSpeedChanged(sender: AnyObject) {
        animationImageView.animationDuration = Double(animationDurationSlider.value)
        startButtonClicked(startButtonView)
    }

}
