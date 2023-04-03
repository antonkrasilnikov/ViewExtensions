import Foundation
import UIKit

class Interface {
    
    enum ScreenSizeType {
        case small
        case base
        case middle
        case large
        case pad
    }
    
    class var size: CGSize {
        return UIScreen.main.bounds.size
    }
    
    class var maxLength: CGFloat {
        return Swift.max(size.width, size.height)
    }
    
    class var minLength: CGFloat {
        return Swift.min(size.width, size.height)
    }
    
    private static var _sizeType: ScreenSizeType?
    private static var _baseMultiplier: CGFloat?
    private static var _scale: CGFloat?
    
    class var sizeType: ScreenSizeType {
        if _sizeType == nil {
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                _sizeType = .pad
            default:
                switch minLength {
                case let w where w >= 414:
                    _sizeType = .large
                case let w where w >= 375:
                    _sizeType = .middle
                default:
                    _sizeType = maxLength < 500 ? .small : .base
                }
            }
        }
        return _sizeType!
    }

    class var sizeMultiplier: CGFloat {
        if _baseMultiplier == nil {
            switch sizeType {
            case .middle:
                _baseMultiplier = 375.0 / 320.0
            case .large:
                _baseMultiplier = 414.0 / 320.0
            case .pad:
                _baseMultiplier = 488.0 / 320.0
            case .base,.small:
                _baseMultiplier = 1
            }
        }
        
        return _baseMultiplier!
    }
    
    class var scale: CGFloat {
        if _scale == nil {
            _scale = UIScreen.main.scale
        }
        return _scale!
    }
    
    class var safeAreaInsets: UIEdgeInsets {
        
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.keyWindow {
                return window.safeAreaInsets
            }
        }
        return .zero
    }

}
