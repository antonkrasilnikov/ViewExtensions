import Foundation
import UIKit

open class GradientView: View {
    
    public var dimension: ColorGradientDimension = .none {
        didSet {
            if oldValue != dimension {
                var startPoint: CGPoint
                var endPoint: CGPoint
                
                switch self.dimension {
                case .horisontal:
                    startPoint = CGPoint.init(x: 0, y: 0.5)
                    endPoint = CGPoint.init(x: 1, y: 0.5)
                case .vertical:
                    startPoint = CGPoint.init(x: 0.5, y: 0)
                    endPoint = CGPoint.init(x: 0.5, y: 1)
                case .leftTopDiagonal:
                    startPoint =  CGPoint.init(x: 0, y: 0)
                    endPoint = CGPoint.init(x: 1, y: 1)
                case .rightTopDiagonal:
                    startPoint = CGPoint.init(x: 1, y: 0)
                    endPoint = CGPoint.init(x: 0, y: 1)
                case .none:
                    startPoint = .zero
                    endPoint = .zero
                }
                
                gradientLayer.startPoint = startPoint
                gradientLayer.endPoint = endPoint
            }
        }
    }
    
    public var colors: [UIColor] = [] {
        didSet {
            if oldValue != self.colors {
                var colorRefs: [CGColor] = []
                
                for color in self.colors {
                    colorRefs.append(color.cgColor)
                }
                
                gradientLayer.colors = colorRefs
            }
        }
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    open override func setup() {
        self.backgroundColor = .clear
    }
        
    open override func setupSizes() {
        
    }
}
