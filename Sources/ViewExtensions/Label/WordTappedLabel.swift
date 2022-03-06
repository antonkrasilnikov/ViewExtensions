import Foundation
import UIKit

public class WordTappedLabel: OnDrawAnimatedView {
    
    public var text: String = "" {
        didSet {
            self.setNeedsDisplay()
        }
    }
    public var textColor: UIColor = .white {
        didSet {
            self.setNeedsDisplay()
        }
    }
    public var backTextColor: UIColor = .gray {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var font: UIFont = UIFont.systemFont(ofSize: 17) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var highlightIndex: Int? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public func setText(word: String, duration: TimeInterval, animated: Bool, comletion: (() -> Void)? = nil) {
        text = word
        
        if animated {
            animate(duration: duration) {
                if let comletion = comletion {
                    comletion()
                }
            }
            setNeedsDisplay()
        }
        
    }
    
    public override func setup() {
        self.backgroundColor = .clear
        
    }
    
    public override func draw(_ rect: CGRect) {
        let string: NSMutableAttributedString = NSMutableAttributedString.init(string: text)
        
        let fontRef = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        
        string.setAttributes([kCTFontAttributeName as NSAttributedString.Key : fontRef], range: NSRange.init(location: 0, length: string.length))
        
        let textColor: UIColor = highlightIndex != nil ? backTextColor : self.textColor
        let backColor: UIColor = highlightIndex == nil ? backTextColor : self.textColor
        
        if animating {
            string.addAttributes([kCTForegroundColorAttributeName as NSAttributedString.Key : backTextColor.cgColor], range: NSRange.init(location: 0, length: string.length))
            let animatedIndex = Int(floor(animationProgress*Double(string.length)))
            if animatedIndex < string.length {
                let alpha = animationProgress*Double(string.length) - Double(animatedIndex)
                let color = backTextColor.withAlphaComponent(CGFloat(alpha))
                string.addAttributes([kCTForegroundColorAttributeName as NSAttributedString.Key : color.cgColor], range: NSRange.init(location: animatedIndex, length: 1))
                
                if animatedIndex < string.length - 1 {
                    
                    string.addAttributes([kCTForegroundColorAttributeName as NSAttributedString.Key : UIColor.clear.cgColor], range: NSRange.init(location: animatedIndex+1, length: string.length - (animatedIndex + 1)))

                }
            }
        }else {
            string.addAttributes([kCTForegroundColorAttributeName as NSAttributedString.Key : textColor.cgColor], range: NSRange.init(location: 0, length: string.length))
            if let highlightIndex = highlightIndex {
                string.addAttributes([kCTForegroundColorAttributeName as NSAttributedString.Key : backColor.cgColor], range: NSRange.init(location: 0, length: highlightIndex >= 0 && highlightIndex <= string.length ? highlightIndex : 0))
            }
            
        }
        
        if let context = UIGraphicsGetCurrentContext() {
            context.textMatrix = .identity
            context.translateBy(x: 0, y: self.bounds.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            
            let line = CTLineCreateWithAttributedString(string as CFAttributedString)
            
            let lineRect = CTLineGetImageBounds(line, context)
            
            context.textPosition = CGPoint(x: (rect.size.width - lineRect.size.width)/2, y: (rect.size.height - lineRect.size.height)/2)
            CTLineDraw(line, context)
        }
        
    }
}
