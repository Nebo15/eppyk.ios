import UIKit

/// A subclass of `UIImageView` that can be animated using an image name string or raw data.
public class AnimatableImageView: UIImageView, AnimatorDelegate {
  /// An `Animator` instance that holds the frames of a specific image in memory.
  var animator: Animator?
  /// A display link that keeps calling the `updateFrame` method on every screen refresh.
  lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: Selector("updateFrame"))

  /// The size of the frame cache.
  public var framePreloadCount = 100

    public var imageName : String = ""
    
    // Delegate
    public weak var delegate: GIFAnimatedImageViewDelegate?

    /// Loops count
    private var goIndex : Int? = nil
    private var _loopsCount = 0
    
    public var loopsCount : Int {
        set {
            _loopsCount = newValue
            guard let animator = self.animator else {
                return
            }
            animator.loopsCount = newValue
        }
        get { return _loopsCount }
    }
    
  /// A computed property that returns whether the image view is animating.
  public var isAnimatingGIF: Bool {
    return !displayLink.paused
  }

  /// Prepares the frames using a GIF image file name, without starting the animation.
  /// The file name should include the `.gif` extension.
  ///
  /// - parameter imageName: The name of the GIF file. The method looks for the file in the app bundle.
  public func prepareForAnimation(imageNamed imageName: String) {
    let imagePath = NSBundle.mainBundle().bundleURL.URLByAppendingPathComponent(imageName)
    prepareForAnimation <^> NSData(contentsOfURL: imagePath)
  }

  /// Prepares the frames using raw GIF image data, without starting the animation.
  ///
  /// - parameter data: GIF image data.
  public func prepareForAnimation(imageData data: NSData) {
    image = UIImage(data: data)
    animator = Animator(data: data, size: frame.size, contentMode: contentMode, framePreloadCount: framePreloadCount)
    animator?.prepareFrames()
    animator?.delegate = self
    attachDisplayLink()
  }

  /// Prepares the frames using a GIF image file name and starts animating the image view.
  ///
  /// - parameter imageName: The name of the GIF file. The method looks for the file in the app bundle.
  public func animateWithImage(named imageName: String) {
    self.imageName = imageName
    prepareForAnimation(imageNamed: imageName)
    animator?.loopsCount = self.loopsCount
    startAnimatingGIF()
  }

  /// Prepares the frames using raw GIF image data and starts animating the image view.
  ///
  /// - parameter data: GIF image data.
  public func animateWithImageData(data: NSData) {
    prepareForAnimation(imageData: data)
    startAnimatingGIF()
  }

    public func goToFrame(index: Int) {
        self.goIndex = index
        self.startAnimatingGIF()
    }
    
  /// Updates the `image` property of the image view if necessary. This method should not be called manually.
  override public func displayLayer(layer: CALayer) {
    image = animator?.currentFrame
  }

    /// Starts the image view animation.
    public func startAnimatingGIF() {
        animator?.currentLoopIndex = 0
        //animator?.currentFrameIndex = 0
        if animator?.isAnimatable ?? false {
            displayLink.paused = false
            if let delegate = self.delegate {
                delegate.gifAnimationDidStart(self.imageName)
            }
        }
    }

  /// Stops the image view animation.
  public func stopAnimatingGIF() {
    self.stopAnimatingGIF(true)
  }
    
    public func stopAnimatingGIF(callout: Bool) {
        displayLink.paused = true
        if let delegate = self.delegate where callout {
            delegate.gifAnimationDidStop(self.imageName, finished: true)
        }
    }

  /// Update the current frame with the displayLink duration
  func updateFrame() {
    if animator?.updateCurrentFrame(displayLink.duration) ?? false {
      layer.setNeedsDisplay()
    }
  }

  /// Invalidate the displayLink so it releases this object.
  deinit {
    displayLink.invalidate()
  }

  /// Attaches the display link.
  func attachDisplayLink() {
    displayLink.addToRunLoop(.mainRunLoop(), forMode: NSRunLoopCommonModes)
  }

    /// AnimatorDelegate
    func animatorFrame(currentFrameIndex: Int) {
        if let goIndex = self.goIndex where goIndex == currentFrameIndex {
            self.goIndex = nil
            self.stopAnimatingGIF(false)
        }
    }
    
    func animatorLoopEnd(currentLoopIndex: Int) {
        if let delegate = self.delegate {
            delegate.gifAnimationDidFinishLoop(self.imageName, loop: currentLoopIndex)
        }
    }
    
    func animatorLastLoopEnd(currentLoopIndex: Int) {
        self.stopAnimatingGIF()
    }
}

public protocol GIFAnimatedImageViewDelegate: class {
    func gifAnimationDidStart(anim: String)
    func gifAnimationDidStop(anim: String, finished: Bool)
    func gifAnimationDidFinishLoop(anim: String, loop: Int)
}