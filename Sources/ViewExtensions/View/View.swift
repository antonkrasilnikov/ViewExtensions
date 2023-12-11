import Foundation
import UIKit

public protocol UserInterface {
    func setup()
    func setupSizes()
}

open class View: UIControl, UserInterface {

    private var sizeSet: Bool = false

    public var tapSound: ControlInteractionSound?

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
            addTarget(self, action: #selector(touchUpSoundAction), for: .touchUpInside)
        }
    }

    open func setupSizes() {

    }

    @objc
    func touchUpSoundAction() {

        guard let tapSound = tapSound else { return }

        if allTargets.count == 1,
           let target = allTargets.first,
           let actions = actions(forTarget: target, forControlEvent: .touchUpInside),
           actions.count == 1 {
            return
        }

        tapSound.play()
    }
}

public extension UIView {

    func snapshot(scale: CGFloat = 0, isOpaque: Bool = false, afterScreenUpdates: Bool = true) -> UIImage? {
        guard bounds.size.width > 0, bounds.size.height > 0 else { return nil }
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

    func subviews<T: UIView>(ofType type: T.Type) -> [T] {

        var ts = (subviews.filter({ $0 is T }) as? [T]) ?? []

        for view in subviews {
            ts.append(contentsOf: view.subviews(ofType: type))
        }

        return ts
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

public extension CGRect {

    /// Initializes a new CGRect with a center point and size.
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - (size.width * 0.5),
                  y: center.y - (size.height * 0.5),
                  width: size.width,
                  height: size.height)
    }


    /// The center point of the rect. Settable.
    var center: CGPoint {
        get {
            return CGPoint(x: midX, y: midY)
        }
        set {
            origin = CGPoint(x: newValue.x - (size.width * 0.5),
                             y: newValue.y - (size.height * 0.5))
        }
    }

    /// The top left point of the rect. Settable.
    var topLeft: CGPoint {
        get {
            return CGPoint(x: minX, y: minY)
        }
        set {
            origin = CGPoint(x: newValue.x,
                             y: newValue.y)
        }
    }

    /// The bottom left point of the rect. Settable.
    var bottomLeft: CGPoint {
        get {
            return CGPoint(x: minX, y: maxY)
        }
        set {
            origin = CGPoint(x: newValue.x,
                             y: newValue.y - size.height)
        }
    }

    /// The top right point of the rect. Settable.
    var topRight: CGPoint {
        get {
            return CGPoint(x: maxX, y: minY)
        }
        set {
            origin = CGPoint(x: newValue.x - size.width,
                             y: newValue.y)
        }
    }

    /// The bottom right point of the rect. Settable.
    var bottomRight: CGPoint {
        get {
            return CGPoint(x: maxX, y: maxY)
        }
        set {
            origin = CGPoint(x: newValue.x - size.width,
                             y: newValue.y - size.height)
        }
    }

}
