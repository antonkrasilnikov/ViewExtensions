import Foundation
import UIKit

open class OutStrokeTextView: View {
    
    public let label = UILabel()
    
    private var _leading: NSLayoutConstraint?
    private var _trailing: NSLayoutConstraint?
    private var _top: NSLayoutConstraint?
    private var _botom: NSLayoutConstraint?
    
    public var strokeColor: UIColor = .clear {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var strokeWidth: CGFloat = 2 {
        didSet {
            _leading?.constant = strokeWidth
            _trailing?.constant = -strokeWidth
            _top?.constant = strokeWidth
            _botom?.constant = -strokeWidth

            setNeedsDisplay()
        }
    }
    
    public var text: String? {
        didSet {
            label.text = text
        }
    }
    
    public override func setup() {
        backgroundColor = .clear
        addSubview(label)
        label.text = text
        
    }
    
    public override func setupSizes() {
        _leading = label.autoPinEdge(toSuperviewEdge: .leading, withInset: strokeWidth)
        _trailing = label.autoPinEdge(toSuperviewEdge: .trailing, withInset: strokeWidth)
        _top = label.autoPinEdge(toSuperviewEdge: .top, withInset: strokeWidth)
        _botom = label.autoPinEdge(toSuperviewEdge: .bottom, withInset: strokeWidth)
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext()
        else {
            return
        }
        
        context.saveGState()
        

        // Outline width
        context.setLineWidth(self.strokeWidth);
        context.setLineJoin(.round)

        // Set the drawing method to stroke
        context.setTextDrawingMode(.stroke)

        // Outline color
        let originalColor = label.textColor
        label.textColor = self.strokeColor
        context.setBlendMode(.copy)
        label.drawText(in: label.frame)
        context.setBlendMode(.normal)
        
        // Invert coordinate system
        context.translateBy(x: 0, y: rect.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.restoreGState()

        label.textColor = originalColor
    }
    
}
