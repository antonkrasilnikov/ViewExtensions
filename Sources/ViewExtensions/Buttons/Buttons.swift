import Foundation
import UIKit

open class Button: View, LoadibleUIControl {
    
    public var isInAction: Bool = false {
        didSet {
            show(isLoading: isInAction)
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
        if self.isEnabled {
            self.alpha = 1
        }else{
            self.alpha = 0.5
        }
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

public protocol LoadibleUIControl: UIView {
    func show(isLoading: Bool)
}

private class LoadibleUIMaskView: View {

    static let loadibleTag = 1764

    let backView = UIView()
    let control = LoadControl(animationType: .line)

    override func setup() {
        super.setup()

        tag = Self.loadibleTag

        addSubview(backView)
        backView.backgroundColor = .init(white: 0, alpha: 0.5)

        addSubview(control)
    }

    override func setupSizes() {
        super.setupSizes()

        backView.autoPinEdgesToSuperviewEdges()
        control.autoCenterInSuperview()
    }

    func show(isLoading: Bool) {
        if isLoading {
            isHidden = true
            if let snapshot = superview?.snapshotView(afterScreenUpdates: true) {
                snapshot.frame = bounds
                backView.mask = snapshot
            }
            isHidden = false
            control.start()
        }else{
            isHidden = true
            control.stop()
        }
    }
}

extension LoadibleUIControl {

    private func _loadibleMaskView() -> LoadibleUIMaskView {

        if let control = subviews.first(where: { $0.tag == LoadibleUIMaskView.loadibleTag }) as? LoadibleUIMaskView {
            bringSubviewToFront(control)
            return control
        }

        let control = LoadibleUIMaskView()
        addSubview(control)
        control.autoPinEdgesToSuperviewEdges()

        return control

    }

    public func show(isLoading: Bool) {
        _loadibleMaskView().show(isLoading: isLoading)
    }
}
