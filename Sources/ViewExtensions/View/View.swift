import Foundation
import UIKit

public protocol UserInterface {
    func setup()
    func setupSizes()
}

open class View: UIControl, UserInterface {
    
    private var sizeSet: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    public init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    public var touchPadding: CGFloat = 0
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
      let extendedBounds = bounds.insetBy(dx: -touchPadding, dy: -touchPadding)
      return extendedBounds.contains(point)
    }
    
    open func setup() {
        
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !sizeSet {
            sizeSet = true
            setupSizes()
        }
    }
    
    open func setupSizes() {
        
    }
}

public extension UIView {

    func snapshot(scale: CGFloat = 0, isOpaque: Bool = false, afterScreenUpdates: Bool = true) -> UIImage? {
       UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, scale)
       drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
       let image = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       return image
    }
}

public extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }

        return nil
    }
}

public extension UIView {
    
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            frame = .init(origin: newValue, size: bounds.size)
        }
    }
    
}
