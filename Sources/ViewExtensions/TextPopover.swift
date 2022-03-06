import Foundation
import UIKit

public class TextPopover: View {
    
    enum AppearanceState {
        case none
        case presenting
        case presented
        case dismissing
    }
    
    public var text: String? {
        didSet {
            label.text = self.text
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    public var backColor: UIColor = .black {
        didSet {
            backLayer.fillColor = self.backColor.cgColor
        }
    }
    
    public var font: UIFont = .systemFont(ofSize: 17) {
        didSet {
            label.font = font
        }
    }
        
    public weak var anchorView: UIView? {
        didSet {
            if let anchorView = self.anchorView, self.superview != nil {
                self.autoPinEdge(.bottom, to: .top, of: anchorView)
                self.autoAlignAxis(.vertical, toSameAxisOf: anchorView).priority = .defaultHigh
                updateBack()
            }
        }
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let anchorView = self.anchorView, self.superview != nil {
            self.autoPinEdge(.bottom, to: .top, of: anchorView)
            self.autoAlignAxis(.vertical, toSameAxisOf: anchorView).priority = .defaultHigh
            updateBack()
        }
        
        if appearanceState == .none {
            appearanceState = .presenting
            
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 1
            }) { (_) in
                if self.appearanceState == .presenting {
                    self.appearanceState = .presented
                }
            }
            
        }
    }
    
    public let label = UILabel()
    
    private let backLayer = CAShapeLayer()
    private var appearanceState: AppearanceState = .none
    
    public override func setup() {
        layer.addSublayer(backLayer)
        backLayer.fillColor = backColor.cgColor
        
        addSubview(label)
        label.isUserInteractionEnabled = false
        label.textColor = .white
        label.font = font
        label.textAlignment = .left
        label.numberOfLines = 0
        
        if text != nil {
            label.text = text
        }
        self.alpha = 0
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        close(animated: true)
        return super.hitTest(point, with: event)
    }
    
    public func close(animated: Bool) {
        
        if appearanceState != .dismissing {
            appearanceState = .dismissing
            
            if animated {
                UIView.animate(withDuration: 0.1, animations: {
                    self.alpha = 0
                }) { (_) in
                    self.appearanceState = .none
                    self.removeFromSuperview()
                }
            }else{
                self.appearanceState = .none
                self.removeFromSuperview()
            }
            
        }
    }
    
    public override func setupSizes() {
        
        let dx: CGFloat = 24
        let dy: CGFloat = 10
        
        self.autoPinEdge(toSuperviewEdge: .leading, withInset: 0, relation: .greaterThanOrEqual)
        self.autoPinEdge(toSuperviewEdge: .trailing, withInset: 0, relation: .greaterThanOrEqual)
        
        label.autoSetDimension(.height, toSize: dy + 24, relation: .greaterThanOrEqual)
        label.autoSetDimension(.width, toSize: 2*dx, relation: .greaterThanOrEqual)
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: dx)
        label.autoPinEdge(toSuperviewEdge: .trailing, withInset: dx)
        label.autoPinEdge(toSuperviewEdge: .top, withInset: dy)
        label.autoPinEdge(toSuperviewEdge: .bottom, withInset: dy + 16)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateBack()
    }
    
    func updateBack() {
        backLayer.frame = bounds
        
        if let anchorView = self.anchorView {
            let path = UIBezierPath()
            
            let r: CGFloat = 24
            let anchorSize: CGSize = .init(width: 40, height: 16)
            let bottomY = bounds.height - anchorSize.height
            
            path.move(to: .init(x: 0, y: r))
            path.addArc(withCenter: .init(x: r, y: r), radius: r, startAngle: .pi, endAngle: .pi*3.0/2.0, clockwise: true)
            path.addLine(to: .init(x: bounds.width - r, y: 0))
            path.addArc(withCenter: .init(x: bounds.width - r, y: r), radius: r, startAngle: -.pi/2, endAngle: 0, clockwise: true)
            path.addLine(to: .init(x: bounds.width, y: bottomY - r))
            path.addArc(withCenter: .init(x: bounds.width - r, y: bottomY - r), radius: r, startAngle: 0, endAngle: .pi/2, clockwise: true)
            
            let anchorCenter = self.convert(.init(x: anchorView.bounds.size.width/2, y: 0), from: anchorView)
            
            path.addLine(to: .init(x: anchorCenter.x + anchorSize.width/2, y: bottomY))
            
            path.addQuadCurve(to: .init(x: anchorCenter.x, y: bottomY + anchorSize.height), controlPoint: .init(x: anchorCenter.x + anchorSize.width*0.3, y: bottomY))
            path.addQuadCurve(to: .init(x: anchorCenter.x - anchorSize.width/2, y: bottomY), controlPoint: .init(x: anchorCenter.x - anchorSize.width*0.3, y: bottomY))
            path.addLine(to: .init(x: r, y: bottomY))
            path.addArc(withCenter: .init(x: r, y: bottomY - r), radius: r, startAngle: .pi/2, endAngle: .pi, clockwise: true)
            
            backLayer.path = path.cgPath
        }else{
            backLayer.path = nil
        }
        
        
    }
    
}
