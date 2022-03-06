import Foundation
import UIKit

open class LoadControl: View {
    
    let activity = UIActivityIndicatorView()

    public var color: UIColor? {
        didSet {
            activity.color = color
        }
    }
    
    open override func setup() {
        activity.hidesWhenStopped = true
        addSubview(activity)
        activity.style = .white
    }
    
    open override func setupSizes() {
        activity.autoCenterInSuperview()
    }
    
    open func start() {
        activity.startAnimating()
    }
    
    open func stop() {
        activity.stopAnimating()
    }
}

open class Button: View {
    
    public lazy var actionControl: LoadControl = { [unowned self] actionControl in
        addSubview(actionControl)
        actionControl.autoCenterInSuperview()
        return actionControl
    }(LoadControl())
    
    public var isInAction: Bool = false {
        didSet {
            if self.isInAction {
                self.isUserInteractionEnabled = false
                actionControl.isHidden = false
                actionControl.start()
            }else{
                self.isUserInteractionEnabled = true
                actionControl.isHidden = true
                actionControl.stop()
            }
            updateColors()
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            updateColors()
        }
    }
    
    open override func setup() {
        super.setup()
        touchPadding = 5
    }
    
    private func updateColors() {
        if self.isEnabled && !self.isInAction {
            self.alpha = 1
        }else{
            self.alpha = 0.5
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.alpha = 0.5
        super.touchesBegan(touches, with: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.alpha = 1
        super.touchesEnded(touches, with: event)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.alpha = 1
        super.touchesCancelled(touches, with: event)
    }
}

public class DetailButton: Button {
    let shapeLayer = CAShapeLayer()
    
    public var color: UIColor = .blue {
        didSet {
            shapeLayer.strokeColor = color.cgColor
        }
    }
    
    public override func setup() {
        layer.addSublayer(shapeLayer)
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.lineCap = .round
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        shapeLayer.frame = bounds
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: .init(x: bounds.width - shapeLayer.lineWidth/2, y: bounds.height/2))
        path.addLine(to: .init(x: 0, y: bounds.height))
        
        shapeLayer.path = path.cgPath
    }
}
