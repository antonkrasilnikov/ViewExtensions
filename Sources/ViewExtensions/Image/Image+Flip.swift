import Foundation
import UIKit

public extension UIImage {
    
    var flippedHorizontaly: UIImage {
        
        guard size.width > 0, size.height > 0 else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else {
            return self
        }
        
        let rect = CGRect(origin: .zero, size: size)
        ctx.draw(cgImage, in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image ?? self
    }
    
    var flippedVerticaly: UIImage {
        
        guard size.width > 0, size.height > 0 else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else {
            return self
        }
        
        ctx.scaleBy(x: -1, y: -1)
        let origin = CGPoint(x: -size.width, y: -size.height)
        let rect = CGRect(origin: origin, size: size)
        ctx.draw(cgImage, in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image ?? self
    }
    
    var rotatedCounterClockwise: UIImage {
        
        guard size.width > 0, size.height > 0 else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return self
        }
        ctx.translateBy(x: size.width/2, y: size.height/2)
        ctx.rotate(by: -.pi/2)
        ctx.translateBy(x: -size.width/2, y: -size.height/2)
        
        self.draw(in: .init(x: 0, y: 0, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image ?? self
    }
    
    var rotatedClockwise: UIImage {
        
        guard size.width > 0, size.height > 0 else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return self
        }
        ctx.translateBy(x: size.width/2, y: size.height/2)
        ctx.rotate(by: .pi/2)
        ctx.translateBy(x: -size.width/2, y: -size.height/2)
        
        self.draw(in: .init(x: 0, y: 0, width: size.width, height: size.height))
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image ?? self
    }
    
}
