import UIKit

public extension UIColor {
    static func colorFromHEX(hex:UInt) -> UIColor {
        
        let red = CGFloat((hex & 0xFF0000) >> 16)/255.0
        let green = CGFloat((hex & 0x00FF00) >>  8)/255.0
        let blue = CGFloat((hex & 0x0000FF) >>  0)/255.0
        
        return UIColor.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    static func colorFromHEX(string: String) -> UIColor {
        let scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = CharacterSet.alphanumerics.inverted
        
        var rgbValue:UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        return colorFromHEX(hex: UInt(rgbValue))
    }

    
    var hex: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String.init(format: "#%02lX%02lX%02lX", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
