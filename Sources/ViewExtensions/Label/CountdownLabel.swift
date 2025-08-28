import Foundation
import UIKit
import Timers

public struct CountdownOptions {
    public let font: UIFont
    public let color: UIColor
    public let strokeColor: UIColor
    public let strokeWidth: CGFloat
}

open class CountdownLabel: UILabel {
    public var options: CountdownOptions?
    private var startValue: Int = 0
    private var currentValue: Int = 0 {
        didSet {
            if oldValue != self.currentValue && self.currentValue >= 0 {
                if let options {
                    self.text = nil
                    self.attributedText = .init(string: "\(self.currentValue)",
                                                attributes: [.font : options.font,
                                                             .foregroundColor : options.color,
                                                             .strokeColor : options.strokeColor,
                                                             .strokeWidth : options.strokeWidth])
                }else{
                    self.attributedText = nil
                    self.text = "\(self.currentValue)"
                }
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
        if let startTs = startTs {
            let ts = INC_SystemUptime.uptime()
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
