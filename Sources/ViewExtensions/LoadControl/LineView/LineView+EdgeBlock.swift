import Foundation
import UIKit

extension LoadControl.LineAnimatedView {

    final class BlockEdgeView: View {

        var moveDistance: CGFloat?
        var keyTimes: [NSNumber]?
        var duration: TimeInterval?

        override func setup() {
            super.setup()
            layer.masksToBounds = true
            layer.cornerRadius = Interface.sizeType == .pad ? 3 : 2
        }

        func start() {
            guard let moveDistance = moveDistance, let keyTimes = keyTimes, let duration = duration else { return }

            let transformAnimation = CAKeyframeAnimation.transformAnimation(values: [CATransform3DScale(layer.transform, 1, 1, 1),
                                                                                     CATransform3DScale(layer.transform, 1.6, 1.0, 1),
                                                                                     CATransform3DScale(layer.transform, 0.7, 0.7, 1),
                                                                                     CATransform3DScale(layer.transform, 0.7, 0.7, 1),
                                                                                     CATransform3DScale(layer.transform, 1, 1, 1)],
                                                                            times: keyTimes,
                                                                            duration: duration,
                                                                            timingFunctionName: .easeOut)

            let moveAnimation = CAKeyframeAnimation(keyPath: "position.x")
            moveAnimation.keyTimes = keyTimes
            moveAnimation.duration = duration
            moveAnimation.isAdditive = true
            moveAnimation.values = [0, moveDistance, moveDistance, -moveDistance, 0]
            moveAnimation.fillMode = .forwards

            let groupAnimation = CAAnimation.groupAnimation(animations: [transformAnimation, moveAnimation], duration: duration, repeatCount: .infinity)
            Animation.animate(caAnimation: groupAnimation, layer: layer, key: "groupAnimation")
        }

        func stop(completion: (() -> Void)? = nil) {
            guard let groupAnimation = layer.animation(forKey: "groupAnimation")?.copy() as? CAAnimation else {
                completion?()
                return
            }
            groupAnimation.repeatCount = 1
            layer.removeAnimation(forKey: "groupAnimation")
            Animation.animate(caAnimation: groupAnimation, layer: layer, key: "groupAnimation") { _ in
                self.layer.removeAnimation(forKey: "groupAnimation")
                completion?()
            }
        }
        
        var isAnimating: Bool {
            layer.animation(forKey: "groupAnimation") != nil
        }
    }
}
