import Foundation
import UIKit

extension LoadControl.BlocksAnimatedView {

    final class BlockView: View {

        var movePosition: (x: CGFloat, y: CGFloat)?
        var keyTimes: [NSNumber]?
        var rotationValues: [CGFloat]?
        var duration: TimeInterval?

        override func setup() {
            super.setup()
            layer.masksToBounds = true
            layer.cornerRadius = Interface.sizeType == .pad ? 3 : 2
        }

        func start() {
            guard let movePosition = movePosition, let keyTimes = keyTimes, let rotationValues = rotationValues, let duration = duration else { return }

            let rotateAnimation = CAKeyframeAnimation.rotateAnimation(values: rotationValues,
                                                                      times: keyTimes,
                                                                      duration: duration)

            let moveXAnimation = CAKeyframeAnimation.traslateXAnimation(values: [0, 0, movePosition.x, movePosition.x, 0],
                                                                        times: keyTimes,
                                                                        duration: duration)

            let moveYAnimation = CAKeyframeAnimation.traslateYAnimation(values: [0, 0, movePosition.y, movePosition.y, 0],
                                                                        times: keyTimes,
                                                                        duration: duration)

            let groupAnimation = CAAnimation.groupAnimation(animations: [rotateAnimation, moveXAnimation, moveYAnimation],
                                                            duration: duration,
                                                            repeatCount: .infinity)

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
    }
}
