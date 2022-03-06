import Foundation
import UIKit

open class CountdownLabel: UILabel {
    
    private var startValue: Int = 0
    private var currentValue: Int = 0 {
        didSet {
            if oldValue != self.currentValue && self.currentValue >= 0 {
                self.text = "\(self.currentValue)"
            }
        }
    }
    private var completion: (() -> Void)?
    private var displayLink: CADisplayLink?
    private var startTs: TimeInterval?
    
    open func animate(startValue: Int, completion: @escaping () -> Void) {
        self.startValue = startValue
        self.currentValue = startValue
        self.completion = completion
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
        
        startTs = INCR_UISystemUptime.uptime()
        
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
        if let startTs = startTs {
            let ts = INCR_UISystemUptime.uptime()
            currentValue = startValue - Int(floor(ts - startTs))
            
            shouldStop = currentValue <= 0
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
