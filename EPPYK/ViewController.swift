//
//  ViewController.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 19/01/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import UIKit

class ViewController: RootViewController, UIDynamicAnimatorDelegate {
    
    //MARK: Config
    let starsCount = 25
    let starsToStayCount = 10

    //MARK: Vars
    @IBOutlet weak var skyView: UIView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var gravityButton: UIButton!
    var stars = [Star]()
    var fixedStars = [Star]()
    var droppedStars = 0

    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        animator = UIDynamicAnimator(referenceView: self.skyView)
        gravity = UIGravityBehavior()
        animator.addBehavior(gravity)
        
        collision = UICollisionBehavior()
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
        animator.delegate = self
        gravityButton.hidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func goClicked(sender: AnyObject) {
        // Clear
        for star in stars {
            collision.removeItem(star)
            gravity.removeItem(star)
            star.removeFromSuperview()
        }
        
        
        stars = [Star]()
        droppedStars = 0
        
        for _ in 0 ... starsCount {
            let star = Star()
            stars.append(star)
            self.skyView.insertSubview(star, atIndex: 0);
            collision.addItem(star)
        }
        gravityButton.hidden = false
    }
    
    @IBAction func gravityClicked(sender: AnyObject) {
        goButton.hidden = true
        gravityButton.hidden = true
        for star in stars {
            NSTimer.scheduledTimerWithTimeInterval(drand48(), target: self, selector: "gravityStars:", userInfo: star, repeats: false)
        }
        
    }
    
    func gravityStars(timer: NSTimer) {
        // Add gravity after delay
        if let star = timer.userInfo {
            gravity.addItem(star as! Star)
            gravity.magnitude = 0.8
            if droppedStars < starsCount - starsToStayCount {
                collision.removeItem(star as! Star)
            }

        }
        droppedStars++
        if droppedStars >= starsCount {
            goButton.hidden = false;
        }
    }
    
}

