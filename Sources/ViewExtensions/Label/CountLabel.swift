import Foundation
import UIKit
import Timers

open class CountLabel: UILabel {
    private var startValue: Int = 0
    private var finalValue: Int = 0
    private var duration: TimeInterval = 0
    private var currentValue: Int = 0 {
        didSet {
            if oldValue != self.currentValue {
                self.text = "\(self.currentValue)"
            }
        }
    }
    private var completion: (() -> Void)?
    private var displayLink: CADisplayLink?
    private var startTs: TimeInterval?
    
    open func animate(from: Int, to: Int, duration: TimeInterval, completion: @escaping () -> Void) {
        self.startValue = from
        self.finalValue = to
        self.currentValue = startValue
        self.duration = duration
        self.completion = completion
        animate()
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
        if let startTs = startTs, duration > 0, startValue != finalValue {
            let ts = INC_SystemUptime.uptime()
            var progress = (ts - startTs)/duration
            progress = progress > 1 ? 1 : progress
            progress = progress < 0 ? 0 : progress
            
            currentValue = startValue + Int(floor(progress*Double(finalValue - startValue)))
                        
            shouldStop = progress >= 1
        }
        if shouldStop {
            self.text = "\(finalValue)"
            removeLink()
            if let completion = completion {
                self.completion = nil
                completion()
            }
        }
    }
}
