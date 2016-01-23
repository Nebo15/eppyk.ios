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
    let starsCount = Int.init(UIScreen.mainScreen().bounds.height / 27)
    var starsToStayCount = 10

    //MARK: Vars
    @IBOutlet weak var skyView: UIView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var gravityButton: UIButton!
    @IBOutlet weak var planetView: UIImageView!
    @IBOutlet weak var dogView: UIImageView!
    @IBOutlet weak var princeView: UIImageView!
    @IBOutlet weak var whatIsYourQuestionLabel: EppykLabelView!
    
    
    //MARK: Starts
    var stars = [Star]()
    var fixedStars = [Star]()
    var droppedStars = 0
    var catchedStar : Star?

    //MARK: Animation & Behaviors
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    var snap: UISnapBehavior!
    
    
    //MARK: Code
    //MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        starsToStayCount = Int.init(Double.init(starsCount) / 2.5)

        animator = UIDynamicAnimator(referenceView: self.skyView)
        gravity = UIGravityBehavior()
        animator.addBehavior(gravity)
        
        collision = UICollisionBehavior()
        collision.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collision)
        
        animator.delegate = self
        
        gravityButton.hidden = true
        self.goClicked(self.goButton)
        print(UIScreen.mainScreen().bounds.height)
        // 568
        // 667
        // 736
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func goClicked(sender: AnyObject) {
        generateStars()
    }
    
    @IBAction func gravityClicked(sender: AnyObject) {
        activateGravity()
    }
    
    //MARK: Shake guester
    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        super.motionEnded(motion, withEvent: event)
        if motion == .MotionShake {
            activateGravity()
        }
    }
    
    func addUICollision() {
//        collision.addItem(planetView)
//        collision.addItem(whatIsYourQuestionLabel)
    }
    
    func removeUICollision() {
//        collision.removeItem(whatIsYourQuestionLabel)
    }
    
    //MARK: Gravity
    
    func generateStars() {
        // Clear
        for star in stars {
            collision.removeItem(star)
            gravity.removeItem(star)
            star.removeFromSuperview()
        }
        
        stars = [Star]()
        droppedStars = 0
        let catchStarIndex = Int.init(arc4random_uniform( UInt32.init(starsCount) ))
        for index in 0 ... starsCount {
            let star = Star()
            stars.append(star)
            var viewIndex = 0
            if index == catchStarIndex {
                viewIndex = 100
                catchedStar = star
            }
            self.skyView.insertSubview(star, atIndex: viewIndex);
            collision.addItem(star)
            star.startGlowing(.Big)
        }
        self.addUICollision()
        gravityButton.hidden = false
    }
    
    func activateGravity() {
        goButton.hidden = true
        gravityButton.hidden = true
        removeUICollision()
        for star in stars {
            NSTimer.scheduledTimerWithTimeInterval(drand48(), target: self, selector: "startGravityForStarByTimer:", userInfo: star, repeats: false)
        }
    }
        
    
    func startGravityForStarByTimer(timer: NSTimer) {
        // Add gravity after delay
        if let star = timer.userInfo {
            if star as? Star == catchedStar {
                collision.removeItem(star as! Star)
                let handPosition = CGPoint.init(x: princeView.frame.origin.x + princeView.frame.size.width, y: princeView.frame.origin.y + princeView.frame.size.height / 2 + 25)
                snap = UISnapBehavior(item: star as! Star, snapToPoint: handPosition)
                snap.damping = 6
                animator.addBehavior(snap)
            } else {
                gravity.addItem(star as! Star)
                gravity.magnitude = 0.8
                if droppedStars < starsCount - starsToStayCount {
                    collision.removeItem(star as! Star)
                }
            }

        }
        droppedStars++
        if droppedStars >= starsCount {
            goButton.hidden = false;
        }
    }
    
}

