import UIKit

public extension UIColor {

    convenience init(hex: UInt, alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/255.0
        let green = CGFloat((hex & 0x00FF00) >>  8)/255.0
        let blue = CGFloat((hex & 0x0000FF) >>  0)/255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    convenience init(hex: String, alpha: CGFloat = 1) {
        let scanner = Scanner(string: hex)
        scanner.charactersToBeSkipped = CharacterSet.alphanumerics.inverted

        var rgbValue:UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(hex: UInt(rgbValue))
    }

    static func colorFromHEX(hex:UInt) -> UIColor {
        .init(hex: hex)
    }
    
    static func colorFromHEX(string: String) -> UIColor {
        .init(hex: string)
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
