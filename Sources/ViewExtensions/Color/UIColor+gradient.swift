import UIKit

public enum ColorGradientDimension {
    case none
    case horisontal
    case vertical
    case leftTopDiagonal
    case rightTopDiagonal
}

public extension UIColor {
    static func gradientColor(colors: [UIColor], size: CGSize, dimension: ColorGradientDimension) -> UIColor? {
        guard size.width > 0, size.height > 0 else { return nil }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        let colorspace = CGColorSpaceCreateDeviceRGB()
        var cg_colors: [CGColor] = []
        for color in colors {
            cg_colors.append(color.cgColor)
        }
        guard let gradient = CGGradient.init(colorsSpace: colorspace, colors: cg_colors as CFArray, locations: nil) else { return nil }
        
        var startPoint: CGPoint?
        var endPoint: CGPoint?
        
        switch dimension {
        case .horisontal:
            startPoint = CGPoint.init(x: 0, y: size.height/2.0)
            endPoint = CGPoint.init(x: size.width, y: size.height/2.0)
        case .vertical:
            startPoint = CGPoint.init(x: size.width/2.0, y: 0)
            endPoint = CGPoint.init(x: size.width/2.0, y: size.height)
        case .leftTopDiagonal:
            startPoint =  CGPoint.init(x: 0, y: 0)
            endPoint = CGPoint.init(x: size.width, y: size.height)
        case .rightTopDiagonal:
            startPoint = CGPoint.init(x: size.width, y: 0)
            endPoint = CGPoint.init(x: 0, y: size.height)
        case .none:
            startPoint = .zero
            endPoint = .zero
        }
        
        
        context?.drawLinearGradient(gradient, start: startPoint!, end: endPoint!, options:CGGradientDrawingOptions.init(rawValue: 0) )
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        UIGraphicsEndImageContext()
        
        return UIColor.init(patternImage: image)
    }
}
