import Foundation
import UIKit

extension UIScrollView {
    func zoom(to zoomPoint: CGPoint, scale: CGFloat, animated: Bool, duration: TimeInterval? = nil, completion: (() -> Void)? = nil) {
        let scale = Swift.max(Swift.min(scale, maximumZoomScale), minimumZoomScale)
        let zoomFactor = 1/zoomScale
        let translatedZoomPoint = CGPoint(x: zoomPoint.x*zoomFactor,
                                          y: zoomPoint.y*zoomFactor)

        let destinationSize = CGSize(width: frame.width/scale,
                                     height: frame.height/scale)
        let destinationRect = CGRect(center: .init(x: translatedZoomPoint.x,
                                                   y: translatedZoomPoint.y),
                                     size: destinationSize)
        if animated, let duration = duration {
            UIView.animate(withDuration: duration) {
                self.zoom(to: destinationRect, animated: false)
            } completion: { _ in

                if self.delegate?.responds(to: #selector(UIScrollViewDelegate.scrollViewDidEndZooming(_:with:atScale:))) == true {
                    self.delegate?.scrollViewDidEndZooming?(self, with: self.delegate?.viewForZooming?(in: self), atScale: scale)
                }

                completion?()
            }
        }else{
            zoom(to: destinationRect, animated: false)
            completion?()
        }
    }
}
