//
//  StartViewController.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 18/02/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation

class StartViewController: RootViewController, L10nViewProtocol, XAnimatedImageViewDelegate {
    
    //MARK: Declarations
    var dogTimer: NSTimer?
    var beginAnimationDone: Bool?
    
    //MARK: UI
    @IBOutlet weak var planetImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var smallLogoImage: UIImageView!
    @IBOutlet weak var globeButton: UIButton!
    
    
    @IBOutlet weak var dogImageView: XAnimatedImageView!
    @IBOutlet weak var princeImageView: XAnimatedImageView!
    @IBOutlet weak var gifStarView: XAnimatedImageView!
    
    @IBOutlet weak var planetButtomConst: NSLayoutConstraint!
    @IBOutlet weak var manLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoTopConst: NSLayoutConstraint!
    
    //MARK: AIs
    var aiStarsBegin: XAnimatedImage?
    var aiStarsDrop: XAnimatedImage?
    var aiManStat: XAnimatedImage?
    var aiDog: [XAnimatedImage?] = []
    var aiMan: [XAnimatedImage?] = []

    
    //MARK: L10nViewProtocol
    func didSelectL10N(l10n: L10n) {
        SettingsManager.sharedInstance.setValue(l10n.code, key: SettingsManager.SelectedL10N)
    }
    
    func didFinish() {
        if self.beginAnimationDone == false {
            self.showMainView()
        }
    }
    
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.beginAnimationDone = false
        
        // Load animation assets
        self.aiStarsBegin = XAnimatedImage(initWithAnimatedGIFData: NSData(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("star_begin@2x", ofType: "gif")!))!)
        self.aiStarsDrop = XAnimatedImage(initWithAnimatedGIFData: NSData(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("star_drop@2x", ofType: "gif")!))!)
        self.aiManStat = XAnimatedImage(initWithAnimatedGIFData: NSData(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("man_stat_1@3x", ofType: "gif")!))!)
        
        // DOG
        self.aiDog.append( XAnimatedImage(initWithAnimatedGIFData: NSData(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("dog_move_1@3x", ofType: "gif")!))!) )
        self.aiDog.append( XAnimatedImage(initWithAnimatedGIFData: NSData(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("dog_move_2@3x", ofType: "gif")!))!) )
        self.aiDog.append( XAnimatedImage(initWithAnimatedGIFData: NSData(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("dog_move_3@3x", ofType: "gif")!))!) )
        self.aiDog.append( XAnimatedImage(initWithAnimatedGIFData: NSData(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("dog_move_4@3x", ofType: "gif")!))!) )

        // MAN
        self.aiMan.append( XAnimatedImage(initWithAnimatedGIFData: NSData(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("man_move_1@3x", ofType: "gif")!))!) )
        self.aiMan.append( XAnimatedImage(initWithAnimatedGIFData: NSData(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("man_move_2@3x", ofType: "gif")!))!) )
        self.aiMan.append( XAnimatedImage(initWithAnimatedGIFData: NSData(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("man_move_3@3x", ofType: "gif")!))!) )
        self.aiMan.append( XAnimatedImage(initWithAnimatedGIFData: NSData(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("man_move_4@3x", ofType: "gif")!))!) )
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Check language settings
        guard let _ = SettingsManager.sharedInstance.getValue(SettingsManager.SelectedL10N) else {
            // Start with language select
            UpdateManager.sharedInstance.updateL10ns({[weak self] (success, l10ns) -> Void in
                if success {
                    self?.showL10NView(l10ns)
                } else {
                    self!.showMainView()
                }
            })
            return
        }

        // Regular start
        self.showMainView()
        
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
    
    func showMainView() {
        
        // Correct constraints for iPhone 5
        if ScreenSize.width == 320 {
            self.manLeftConstraint.constant += 10;
            self.view.layoutIfNeeded()
        }
        
        // Star brgin animation
        self.gifStarView.animatedImage = self.aiStarsBegin
        self.gifStarView.loopCountdown = 1
        self.gifStarView.delegate = self
        self.gifStarView.startAnimating()
        
        // Man animation
        self.princeImageView.animatedImage = self.aiManStat
        self.princeImageView.delegate = self
        self.princeImageView.startAnimating()
        
        // Dog timer
        dogTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: "moveDog", userInfo: nil, repeats: true)
        
        // Logo & planet animation
        let logoRect = self.logoImage.bounds
        let startLogoRect = CGRectMake(0, 0, logoRect.size.width / 2.1, logoRect.size.height / 2.1)
        let finalLogoRect = CGRectMake(0, 0, logoRect.size.width / 2.0, logoRect.size.height / 2.0)

        let planetHeight = self.planetImage.bounds.size.height
        self.planetButtomConst.constant = planetHeight / 1.6 * -1
        self.logoTopConst.constant = -25

        UIView.animateWithDuration(self.gifStarView.animatedImage.xAnimationDuration - self.gifStarView.animatedImage.xAnimationDuration/2, delay: self.gifStarView.animatedImage.xAnimationDuration/2, options: .CurveEaseInOut, animations: {[weak self] () -> Void in
            self?.view.layoutIfNeeded()
            self?.logoImage.bounds = startLogoRect

            }, completion: {[weak self] (Bool) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    // Bounce
                    self?.planetButtomConst.constant += 4;
                    self?.view.layoutIfNeeded()
                    self?.logoImage.bounds = finalLogoRect
                    }, completion: { (Bool) -> Void in
                        self?.logoImage.hidden = true
                        self?.smallLogoImage.hidden = false
                        self?.beginAnimationDone = true
                })
        })
    }

    //MARK: xAnimation
    func xAnimationDidStart(anim: XAnimatedImage) {
        
    }
    
    func xAnimationDidStop(anim: XAnimatedImage, finished: Bool) {
        if anim == aiStarsBegin! {
            self.gifStarView.animatedImage = self.aiStarsBegin
            self.gifStarView.loopCountdown = 1
            self.gifStarView.startAnimating()
        }
        
        if anim == aiMan[0]! || anim == aiMan[1]! || anim == aiMan[2]! || anim == aiMan[3]! {
            self.princeImageView.animatedImage = self.aiManStat
            self.princeImageView.startAnimating()
        }
    }
    
    func xAnimationDidFinishLoop(anim: XAnimatedImage, loop: Int) {
        print(loop)
        if anim == self.aiManStat! {
            // Map animation loop over
            if arc4random_uniform(4) == 0 {
                let moveIndex = Int.init(arc4random_uniform(UInt32.init(aiMan.count)))
                print("Man extra move \(moveIndex)")
                moveMan(moveIndex)
            }
        }
    }
    
    //MARK: Animation actions
    func moveMan(let moveIndex: Int) {
        self.princeImageView.animatedImage = self.aiMan[moveIndex]
        self.princeImageView.loopCountdown = 1
        self.princeImageView.delegate = self
        self.princeImageView.startAnimating()
    }

    func moveDog() {
        if arc4random_uniform(3) != 0 {
            return;
        }
        let moveIndex = Int.init(arc4random_uniform(UInt32.init(aiDog.count)))
        print("Dog extra move \(moveIndex)")
        
        self.dogImageView.animatedImage = self.aiDog[moveIndex]
        self.dogImageView.loopCountdown = 1
        self.dogImageView.delegate = self
        self.dogImageView.startAnimating()
    }

    //MARK: Actions
    @IBAction func showL10View(sender: AnyObject) {
        // Start with language select
        self.globeButton.userInteractionEnabled = false
        UpdateManager.sharedInstance.updateL10ns({[weak self] (success, l10ns) -> Void in
            self?.globeButton.userInteractionEnabled = true
            if success {
                self?.showL10NView(l10ns)
            } else {
                self!.showMainView()
            }
            })
    }
    
}
