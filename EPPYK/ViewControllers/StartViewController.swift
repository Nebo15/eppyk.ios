//
//  StartViewController.swift
//  EPPYK
//
//  Created by Anton Rogachevskiy on 18/02/16.
//  Copyright © 2016 Anton Rogachevskyi. All rights reserved.
//

import Foundation
import Gifu
import AFNetworking
import Mixpanel

enum GIFAnimationType: String {
    case GIFStarsBegin = "star_begin@2x.gif"
    case GIFStarsDrop = "star_drop@2x.gif"
    case GIFStarsBack = "star_back@2x.gif"
    
    case GIFManStat = "man_stat_1@3x.gif"
    case GIFManStatWithStar = "man_stat_2@3x.gif"
    case GIFManStarCatch = "man_star_catch@3x.gif"
    case GIFManStarDrop = "man_star_drop@3x.gif"
    
    case GIFHandShake = "hand@3x.gif"
    
}

class StartViewController: RootViewController, L10nViewProtocol, GIFAnimatedImageViewDelegate, UITextFieldDelegate {
    
    //MARK: Declarations
    var dogTimer: NSTimer?
    var handTimer: NSTimer?
    var beginAnimationDone: Bool?
    var canShake: Bool?
    
    //MARK: UI
    @IBOutlet weak var saveAnswerButton: UIButton!
    
    @IBOutlet weak var tryAgainButton: UIButton!
    
    @IBOutlet weak var planetImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var smallLogoImage: UIImageView!
    @IBOutlet weak var globeButton: UIButton!
    
    @IBOutlet weak var whatQuestionText: EppykLabelView!
    @IBOutlet weak var questionTextField: EppykTextField!
    @IBOutlet weak var shakeText: EppykLabelView!
    @IBOutlet weak var answerLabelView: EppykLabelView!
    @IBOutlet weak var questionLabelView: EppykLabelView!
    
    
    @IBOutlet weak var userControlsView: UIView!
    @IBOutlet weak var logosView: UIView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var answerView: UIView!
    
    
    @IBOutlet weak var handImageView: AnimatableImageView!
    @IBOutlet weak var dogImageView: AnimatableImageView!
    
    @IBOutlet weak var manImageView: AnimatableImageView!
    @IBOutlet weak var gifStarViewBegin: AnimatableImageView!
    @IBOutlet weak var gifStarViewBack: AnimatableImageView!

    @IBOutlet weak var gifStarViewDrop: AnimatableImageView!
    
    //MARK: Constraints
    @IBOutlet weak var planetButtomConst: NSLayoutConstraint!
    @IBOutlet weak var manLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoTopConst: NSLayoutConstraint!
    @IBOutlet weak var shakeBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var handBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var questionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var whatQuestionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var answerBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var buttonSaveWidth: NSLayoutConstraint!
    @IBOutlet weak var buttonSaveLeft: NSLayoutConstraint!
    
    
    @IBOutlet weak var buttonTryWidth: NSLayoutConstraint!
    @IBOutlet weak var buttonTryRight: NSLayoutConstraint!
    
    @IBOutlet weak var questionLabelWidthConstraint: NSLayoutConstraint!
    var mixpanel: Mixpanel?
    
    var aiDog: [String] = []
    var aiMan: [String] = []
    
    //MARK: L10nViewProtocol
    func didSelectL10N(l10n: L10n) {
        self.mixpanel!.track("Localization selected", properties: ["L10N": l10n.code])
        SettingsManager.sharedInstance.setValue(l10n.code, key: SettingsManager.SelectedL10N)
    }
    
    func didFinish() {
        self.mixpanel!.track("Finish localization selection")
        if let l10n = SettingsManager.sharedInstance.getValue(SettingsManager.SelectedL10N) {
            UpdateManager.sharedInstance.updateAnswers( l10n );
        }
        
        if self.beginAnimationDone == false {
            self.showMainView()
        }
    }
    
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mixpanel = Mixpanel.sharedInstanceWithToken("ee8c37904fb6e9b30bb56b3a945c9dad")
        
        self.beginAnimationDone = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Correct constraints for iPhone 5
        if ScreenSize.width == 320 {
            self.manLeftConstraint.constant += 10;
            self.view.layoutIfNeeded()
        }
        
        self.configButtons()
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

    func dismissKeyboard() {
        self.view.endEditing(true)
    }

    
    func showL10NView(data: [L10n]) {
        if let view = UIView.loadFromNibNamed("L10nView") {
            self.mixpanel!.track("Language select show")
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
        
        self.mixpanel!.track("Application start")
        self.loadGIFs()
        
        self.gifAnimation(.GIFStarsBegin)
        
        self.manImageView.animateWithImage(named: GIFAnimationType.GIFManStat.rawValue)
        self.manImageView.delegate = self
        
        // Dog & hand timer
        dogTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(self.moveDog), userInfo: nil, repeats: true)
        handTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(self.moveHand), userInfo: nil, repeats: true)
        
        // Config UI
        self.questionTextField.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard) )
        self.userControlsView.addGestureRecognizer(tap)
        

        // Logo & planet start animation
        let logoRect = self.logoImage.bounds
        let startLogoRect = CGRectMake(0, 0, logoRect.size.width / 2.1, logoRect.size.height / 2.1)
        let finalLogoRect = CGRectMake(0, 0, logoRect.size.width / 2.0, logoRect.size.height / 2.0)

        let planetHeight = self.planetImage.bounds.size.height
        self.planetButtomConst.constant = planetHeight / 1.6 * -1
        self.logoTopConst.constant = -7

        UIView.animateWithDuration(0.8, delay: 1, options: .CurveEaseInOut, animations: {[weak self] () -> Void in
            self?.logosView.layoutIfNeeded()
            self?.view.layoutIfNeeded()
            self?.logoImage.bounds = startLogoRect

            }, completion: {[weak self] (Bool) -> Void in

                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    // Bounce
                    self?.planetButtomConst.constant += 4;
                    self?.logosView.layoutIfNeeded()
                    self?.logoImage.bounds = finalLogoRect
                    }, completion: { (Bool) -> Void in
                        self?.logoImage.hidden = true
                        self?.smallLogoImage.hidden = false
                        self?.beginAnimationDone = true
                        self?.canShake = true
                })
        })
        
        self.showUIControls()
        
    }
    
    

    //MARK: xAnimation
    func gifAnimationDidStart(anim: String) {
        
    }
    
    func gifAnimationDidStop(anim: String, finished: Bool) {
        
        if aiMan.contains(anim) {
            self.manImageView.animateWithImage(named: GIFAnimationType.GIFManStat.rawValue)
            self.manImageView.loopsCount = 0
        }
        
        if anim == GIFAnimationType.GIFManStarCatch.rawValue {
            self.manImageView.animateWithImage(named: GIFAnimationType.GIFManStatWithStar.rawValue)
            self.manImageView.loopsCount = 0
            
            // Show control buttons
            UIView.animateWithDuration(1, delay: 1, options: .CurveEaseInOut, animations: { () -> Void in
                }, completion: { (Bool) -> Void in
                })
        }
        
        if anim == GIFAnimationType.GIFManStarDrop.rawValue {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.manImageView.animateWithImage(named: GIFAnimationType.GIFManStat.rawValue)
                dispatch_async(dispatch_get_main_queue(), {
                    self.manImageView.delegate = self
                    self.manImageView.loopsCount = 0
                });
            });
        }
        
        
    }
    
    func gifAnimationDidFinishLoop(anim: String, loop: Int) {
        if anim == GIFAnimationType.GIFManStat.rawValue && self.manImageView.imageName == GIFAnimationType.GIFManStat.rawValue {
            // Map animation loop over
            if arc4random_uniform(6) == 0 {
                let moveIndex = Int.init(arc4random_uniform(UInt32.init(aiMan.count)))
                moveMan(moveIndex)
            }
        }
    }
    
    //MARK: Animation actions
    
    func loadGIFs() {
        self.gifStarViewBegin.animateWithImage(named: GIFAnimationType.GIFStarsBegin.rawValue)
        self.gifStarViewBegin.loopsCount = 1
        self.gifStarViewBegin.delegate = self
        self.gifStarViewBegin.stopAnimatingGIF(false)

        
        self.gifStarViewDrop.animateWithImage(named: GIFAnimationType.GIFStarsDrop.rawValue)
        self.gifStarViewDrop.loopsCount = 1
        self.gifStarViewDrop.delegate = self
        self.gifStarViewDrop.stopAnimatingGIF(false)
        
        
        self.gifStarViewBack.animateWithImage(named: GIFAnimationType.GIFStarsBack.rawValue)
        self.gifStarViewBack.loopsCount = 1
        self.gifStarViewBack.delegate = self
        self.gifStarViewBack.stopAnimatingGIF(false)
        self.gifStarViewBack.hidden = true
        
        
        // DOG
        self.aiDog.append("dog_move_1@3x.gif")
        self.aiDog.append("dog_move_2@3x.gif")
        self.aiDog.append("dog_move_3@3x.gif")
        self.aiDog.append("dog_move_4@3x.gif")
        
//        for image: String in self.aiMan {
//            self.dogImageView.animateWithImage(named: image)
//        }
//        self.dogImageView.stopAnimatingGIF()
        
        
        // MAN
        self.aiMan.append("man_move_1@3x.gif")
        self.aiMan.append("man_move_2@3x.gif")
        self.aiMan.append("man_move_3@3x.gif")
        self.aiMan.append("man_move_4@3x.gif")
        
        self.manImageView.animateWithImage(named: GIFAnimationType.GIFManStarDrop.rawValue)
        self.manImageView.animateWithImage(named: GIFAnimationType.GIFManStarCatch.rawValue)
        self.manImageView.animateWithImage(named: GIFAnimationType.GIFManStatWithStar.rawValue)
        
//        for image: String in self.aiMan {
//            self.manImageView.animateWithImage(named: image)
//        }
        self.manImageView.stopAnimatingGIF()
        
        
    }
    
    func stopAllAnimation() {
        handImageView.stopAnimatingGIF(false)
        dogImageView.stopAnimatingGIF(false)
        manImageView.stopAnimatingGIF(false)
        gifStarViewBegin.stopAnimatingGIF(false)
        gifStarViewBack.stopAnimatingGIF(false)
        gifStarViewDrop.stopAnimatingGIF(false)
        
        handTimer?.invalidate()
        dogTimer?.invalidate()
        
    }
    
    func gifAnimation(type: GIFAnimationType) {
        switch type {

        case .GIFStarsBegin:
            // Star brgin animation
            self.gifStarViewBegin.hidden = false;
            self.gifStarViewBegin.startAnimatingGIF()

            break
            
        case .GIFStarsDrop:
            
            // Star brgin animation
            
            self.gifStarViewBegin.hidden = true;
            self.gifStarViewBegin.goToFrame(1)
            self.gifStarViewBack.hidden = true;
            self.gifStarViewBack.goToFrame(1)
            
            self.gifStarViewDrop.hidden = false;
            self.gifStarViewDrop.startAnimatingGIF()

            
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.6 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.manImageView.animateWithImage(named: GIFAnimationType.GIFManStarCatch.rawValue)
                self.manImageView.delegate = self
                self.manImageView.loopsCount = 1
            })
            
            break
            
        case .GIFStarsBack:
            
            self.gifStarViewBegin.hidden = true;
            self.gifStarViewBegin.goToFrame(1)
            self.gifStarViewDrop.hidden = true;
            self.gifStarViewDrop.goToFrame(1)
            
            self.gifStarViewBack.hidden = false;
            self.gifStarViewBack.startAnimatingGIF()

            break
            
        default:
            break
        }
    }
    
    
    func showTryAgainAnimation() {
        
        self.gifAnimation(.GIFStarsBack)
        
        // Drop star
        self.manImageView.animateWithImage(named: GIFAnimationType.GIFManStarDrop.rawValue)
        self.manImageView.delegate = self
        self.manImageView.loopsCount = 1
        
        // Hide buttons
        self.hideButtons()
    }
    
    func moveMan(let moveIndex: Int) {
        print("Man extra move \(moveIndex)")
        self.manImageView.animateWithImage(named: self.aiMan[moveIndex])
        self.manImageView.loopsCount = 1
        self.manImageView.delegate = self
    }

    func moveDog() {
        if arc4random_uniform(3) != 0 {
            return;
        }
        let moveIndex = Int.init(arc4random_uniform(UInt32.init(aiDog.count)))
        print("Dog extra move \(moveIndex)")
        
        self.dogImageView.animateWithImage(named: self.aiDog[moveIndex])
        self.dogImageView.loopsCount = 1
        self.dogImageView.delegate = self
    }
    
    func moveHand() {
        self.handImageView.animateWithImage(named: GIFAnimationType.GIFHandShake.rawValue)
        self.handImageView.loopsCount = 2
        self.handImageView.delegate = self
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.mixpanel!.track("Go press for answer", properties: ["Question": questionTextField.text!])
        self.getAnswer()
        return true
    }
    
    //MARK: Shake guester
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        super.motionEnded(motion, withEvent: event)
        
        if !self.answerView.hidden && self.canShake! {
            self.mixpanel!.track("Shake for another answer", properties: ["Question": questionTextField.text!])
            self.refreshAnswer()
        } else if motion == .MotionShake && self.canShake! && !self.questionTextField.text!.isEmpty {
            self.mixpanel!.track("Shake for answer", properties: ["Question": questionTextField.text!])
            self.getAnswer()
        }
    }
    
    
    //MARK: UI Actions
    func configButtons() {
        self.buttonSaveWidth.constant = (ScreenSize.width - 50) / 2
        self.buttonTryWidth.constant = (ScreenSize.width - 50) / 2
        buttonsView.layoutIfNeeded()
        
        self.buttonSaveLeft.constant = 0 - (self.buttonSaveWidth.constant + 20)
        self.buttonTryRight.constant = 0 - (self.buttonTryWidth.constant + 20)

        buttonsView.layoutIfNeeded()
    }
    
    func showButtons() {
        
        UIView.animateWithDuration(1.5, delay: 1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self] () -> Void in
            self?.buttonSaveLeft.constant = 20
            self?.buttonTryRight.constant = 20
            
            self?.buttonsView.layoutIfNeeded()
        }) { (Bool) -> Void in
        }
        
    }
    
    func hideButtons() {
        
        UIView.animateWithDuration(0.3, delay: 0.9, options: .CurveEaseInOut, animations: {[weak self] () -> Void in
            self?.buttonSaveLeft.constant = 30
            self?.buttonTryRight.constant = 30
            self?.buttonsView.layoutIfNeeded()
            
            }, completion: {[weak self] (Bool) -> Void in
                
                UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self] () -> Void in
                    self?.buttonSaveLeft.constant = 0 - ((self?.buttonSaveWidth.constant)! + 20)
                    self?.buttonTryRight.constant = 0 - ((self?.buttonTryWidth.constant)! + 20)
                    
                    self?.buttonsView.layoutIfNeeded()
                }) { (Bool) -> Void in
                }
                
            })
    }
    
    func hideAnswer(hideQuestion: Bool, completion: (() -> Void)?) {
        
        if ScreenSize.width == 320 {
            self.answerBottomConstraint.constant = 200
        } else {
            self.answerBottomConstraint.constant = 300
        }
        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: {[weak self] () -> Void in
            self?.answerLabelView.alpha = 0
            if hideQuestion {
                self?.questionLabelView.alpha = 0
                self?.questionLabelWidthConstraint.constant = 0
            }
            
            self?.answerView.layoutIfNeeded()
        }) { (Bool) -> Void in
            self.answerControlsToStartPosition()
            if let _completion = completion {
                _completion()
            }
        }
    }
    

    func uiControlsToStartPosition() {
        self.shakeText.alpha = 0
        self.handImageView.alpha = 0
        self.questionTextField.alpha = 0
        self.whatQuestionText.alpha = 0
        self.shakeBottomConstraint.constant = 240
        self.handBottomConstraint.constant = 240
        self.questionBottomConstraint.constant = 221
        self.whatQuestionBottomConstraint.constant = 240
        self.userControlsView.layoutIfNeeded()
        self.questionTextField.text = "";
    }
    
    func answerControlsToStartPosition() {
        self.answerLabelView.hidden = true
        self.answerView.hidden = true
        self.answerLabelView.alpha = 0
        self.answerBottomConstraint.constant = 95
        self.answerView.layoutIfNeeded()
    }
    
    
    func showUIControls() {
        
        self.uiControlsToStartPosition()
        
        var offset: CGFloat = 40
        
        if ScreenSize.width == 320 {
            offset = 5
        }
        
        // User controls start animation
        self.shakeBottomConstraint.constant += offset
        self.handBottomConstraint.constant += offset + 25
        self.questionBottomConstraint.constant += offset + 85
        self.whatQuestionBottomConstraint.constant += offset + 110
        
        UIView.animateWithDuration(1.5, delay: 1.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self] () -> Void in
            
            self?.userControlsView.layoutIfNeeded()
            self?.shakeText.alpha = 0.9
            self?.handImageView.alpha = 0.9
            self?.questionTextField.alpha = 0.9
            self?.whatQuestionText.alpha = 0.9
            
        }) { (Bool) -> Void in
        }
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
    
    
    func getAnswer() {
        self.canShake = false
        
        self.view.endEditing(true)
        self.dropStars()
    }
    
    func refreshAnswer() {
        self.canShake = false
        self.hideAnswer(false) {
            self.answerLabelView.text = QAManager.sharedInstance.fetchAnswer()
            self.questionLabelView.sizeToFit()
            self.showAnswer()
        }
        
    }
    
    func dropStars() {
        
        self.gifAnimation(.GIFStarsDrop)
        
        
        // User controls start animation
        self.shakeBottomConstraint.constant += 120
        self.handBottomConstraint.constant += 110
        self.questionBottomConstraint.constant += 100
        self.whatQuestionBottomConstraint.constant += 90
        
        UIView.animateWithDuration(0.8, delay: 0.5, options: .CurveEaseInOut, animations: {[weak self] () -> Void in
            self?.userControlsView.layoutIfNeeded()
            self?.shakeText.alpha = 0
            self?.handImageView.alpha = 0
            self?.questionTextField.alpha = 0
            self?.whatQuestionText.alpha = 0
            
        }) { (Bool) -> Void in
            self.questionLabelView.text = self.questionTextField.text
            self.questionLabelView.sizeToFit()

            self.showAnswer()
            self.showButtons()
        }
    }
    
    func showAnswer() {
        self.answerLabelView.text = QAManager.sharedInstance.fetchAnswer()
        self.answerView.hidden = false
        self.answerLabelView.hidden = false
        
        if ScreenSize.width == 320 {
            self.answerBottomConstraint.constant = 170
        } else {
            self.answerBottomConstraint.constant = 250
        }
        
        UIView.animateWithDuration(1.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {[weak self] () -> Void in
            
            self?.questionLabelWidthConstraint.constant = (self?.questionLabelView.bounds.size.width)!
            
            self?.questionLabelView.alpha = 0.9
            self?.answerLabelView.alpha = 0.9
            self?.answerView.layoutIfNeeded()
        }) { (Bool) -> Void in
            self.canShake = true
        }
    }
    
    @IBAction func makeScreenshot(sender: AnyObject) {
        self.mixpanel!.track("Screenshot pressed")
        
        (sender as! UIButton).transform = CGAffineTransformMakeScale(0.8, 0.8)
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: CGFloat(0.40), initialSpringVelocity: CGFloat(0), options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            (sender as! UIButton).transform = CGAffineTransformIdentity
        }) { (ok: Bool) -> Void in
            // Animation
            self.screenShotFlash()
            
            let view = self.view
            self.buttonsView.hidden = true
            self.globeButton.hidden = true
            let image = ImageManager.sharedInstance.screenshotView(view)
            self.buttonsView.hidden = false
            self.globeButton.hidden = false
            ImageManager.sharedInstance.saveImageToGallery(image) { (success: Bool, error: NSError?) -> Void in
                print(success ? "OK" : error!.localizedDescription)
            }
        }
        
    }
    
    func screenShotFlash() {
        let aView = UIView(frame: self.view.bounds)
        aView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(aView)
        
        UIView.animateWithDuration(0.8, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            aView.alpha = 0.0
            }, completion: { (done) -> Void in
                aView.removeFromSuperview()
        })
    }
    
    
    @IBAction func makeTryAgain(sender: AnyObject) {
        self.mixpanel!.track("Try again pressed")
        
        (sender as! UIButton).transform = CGAffineTransformMakeScale(0.8, 0.8)
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: CGFloat(0.40), initialSpringVelocity: CGFloat(0), options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            (sender as! UIButton).transform = CGAffineTransformIdentity
        }) { (ok: Bool) -> Void in

            self.showTryAgainAnimation()
            self.showUIControls()
            self.hideAnswer(true, completion: nil)
            self.canShake = true
        }
    }
    
}
