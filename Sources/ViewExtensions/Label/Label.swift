import Foundation
import UIKit

public extension UILabel {
    func setFontSize(_ size: CGFloat) {
        self.font = UIFont.init(name: self.font.fontName, size: size)
    }
    
    func adoptFontSize(fontSize1: CGFloat, size1: CGFloat, fontSize2: CGFloat, size2: CGFloat, size: CGFloat, maxFontSize: CGFloat? = nil) {
        let a = (fontSize2 - fontSize1)/(size2 - size1)
        let b = fontSize1 - a*size1
        var f = a*size + b
        
        if let maxFontSize = maxFontSize, f > maxFontSize {
            f = maxFontSize
        }
        
        setFontSize(f)
    }
}
