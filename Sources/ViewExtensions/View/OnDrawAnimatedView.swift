import Foundation
import UIKit
import Timers

open class OnDrawAnimatedView: View {
    private var completion: (() -> Void)?
    private var displayLink: CADisplayLink?
    private var startTs: TimeInterval?
    private var duration: TimeInterval = 0
    public var animationProgress: Double = 0
    
    public var animating: Bool {
        return displayLink != nil
    }
    
    open func animate(duration: TimeInterval, completion: @escaping () -> Void) {
        self.completion = completion
        self.duration = duration
        animate()
    }
    
    open func stopAnimation() {
        removeLink()
        completion = nil
    }
    
    public override func removeFromSuperview() {
        removeLink()
        super.removeFromSuperview()
    }
    
    private func animate() {
        
        startTs = INC_SystemUptime.uptime()
        
        addLink()
    }
    
    private func addLink() {
        if displayLink == nil {
            displayLink = CADisplayLink.init(target: self, selector: #selector(displayLinkAction))
            displayLink?.add(to: RunLoop.main, forMode: .common)
        }
    }
    
    private func removeLink() {
        if displayLink != nil {
            displayLink!.remove(from: RunLoop.main, forMode: .common)
            displayLink = nil
        }
    }
    
    @objc private func displayLinkAction() {
        var shouldStop = true
        if let startTs = startTs, duration > 0 {
            let ts = INC_SystemUptime.uptime()
            var progress = (ts - startTs)/duration
            progress = progress > 1 ? 1 : progress
            progress = progress < 0 ? 0 : progress
            
            animationProgress = progress
            setNeedsDisplay()
            
            shouldStop = animationProgress >= 1
            
        }
        if shouldStop {
            removeLink()
            if let completion = completion {
                self.completion = nil
                completion()
            }
        }
    }
}
