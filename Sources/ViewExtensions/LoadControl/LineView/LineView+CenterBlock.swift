import Foundation
import UIKit

extension LoadControl.LineAnimatedView {

    final class BlockCenterView: View {
        var duration: TimeInterval?

        override func setup() {
            super.setup()
            layer.masksToBounds = true
            layer.cornerRadius = Interface.sizeType == .pad ? 3 : 2
        }

        func start() {
            guard let duration = duration else { return }

            let transformAnimation = CAKeyframeAnimation.transformAnimation(values: [CATransform3DScale(layer.transform, 1, 1, 1),
                                                                                     CATransform3DScale(layer.transform, 1.7, 1.7, 1),
                                                                                     CATransform3DScale(layer.transform, 1, 1, 1),
                                                                                     CATransform3DScale(layer.transform, 0.6, 1.7, 1),
                                                                                     CATransform3DScale(layer.transform, 1, 1, 1)],
                                                                            times: [0, 0.25, 0.6, 0.75, 1],
                                                                            duration: duration,
                                                                            repeatCount: .infinity,
                                                                            timingFunction: .linear)
            Animation.animate(caAnimation: transformAnimation, layer: layer, key: "transormAnimation")
        }

        func stop(completion: (() -> Void)? = nil) {
            guard let transormAnimation = layer.animation(forKey: "transormAnimation")?.copy() as? CAAnimation else {
                completion?()
                return
            }
            transormAnimation.repeatCount = 1
            layer.removeAnimation(forKey: "transormAnimation")
            Animation.animate(caAnimation: transormAnimation, layer: layer, key: "transormAnimation") { _ in
                self.layer.removeAnimation(forKey: "transormAnimation")
                completion?()
            }
        }
        
        var isAnimating: Bool {
            layer.animation(forKey: "transormAnimation") != nil
        }
    }
}
