import Foundation
import UIKit

extension LoadControl {

    final class BlocksAnimatedView: View, LoadView {

        private let block1 = BlockView()
        private let block2 = BlockView()
        private let block3 = BlockView()
        private let block4 = BlockView()

        private var blocks: [BlockView] {
            [block1, block2, block3, block4]
        }

        var color: UIColor? {
            didSet {
                blocks.forEach {
                    $0.backgroundColor = color
                }
            }
        }

        private let duration: TimeInterval = 1.3
        private let keyTimes: [NSNumber] = [0, 0.1, 0.25, 0.8, 1]

        private enum _AnimationState {
            case none
            case animation
            case stopAnimation
            case waitForRestart
        }

        private var animationState: _AnimationState = .none

        override func setup() {
            super.setup()
            isHidden = true

            let moveValue: CGFloat = Interface.sizeType == .pad ? 6 : 4
            block1.movePosition = (x: -moveValue, y: -moveValue)
            block2.movePosition = (x: -moveValue, y: moveValue)
            block3.movePosition = (x: moveValue, y: -moveValue)
            block4.movePosition = (x: moveValue, y: moveValue)

            let rotateValues = [0, 0, Double.pi/2, Double.pi, Double.pi].map({ CGFloat($0) })
            block1.rotationValues = rotateValues.map({ -$0 })
            block2.rotationValues = rotateValues
            block3.rotationValues = rotateValues
            block4.rotationValues = rotateValues.map({ -$0 })

            blocks.forEach {
                $0.duration = duration
                $0.keyTimes = keyTimes
                addSubview($0)
            }
        }

        override func setupSizes() {
            super.setupSizes()

            let size: CGSize = Interface.sizeType == .pad ? .init(width: 12, height: 12) : .init(width: 8, height: 8)
            let spacing: CGFloat = Interface.sizeType == .pad ? 2 : 1

            let offset: CGFloat = (size.height / 2) + spacing

            block1.autoSetDimensions(to: size)
            block1.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: -offset)
            block1.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: -offset)

            block2.autoSetDimensions(to: size)
            block2.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: offset)
            block2.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: -offset)

            block3.autoSetDimensions(to: size)
            block3.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: -offset)
            block3.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: offset)

            block4.autoSetDimensions(to: size)
            block4.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: offset)
            block4.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: offset)
        }

        func start() {
            guard animationState == .none else {
                switch animationState {
                case .stopAnimation:
                    animationState = .waitForRestart
                case .animation:
                    if layer.animation(forKey: "groupAnimation") == nil {
                        _startAnimation()
                    }
                default:
                    break
                }
                return
            }

            animationState = .animation

            isHidden = false
            
            _startAnimation()
        }
        
        private func _startAnimation() {
            CATransaction.begin()

            let rotateAnimation = CAKeyframeAnimation.rotateAnimation(values: [0, 0, Double.pi/2, Double.pi, Double.pi*2].map({ CGFloat($0) }),
                                                                      times: keyTimes,
                                                                      duration: duration)

            let scaleAnimation = CAKeyframeAnimation.scaleAnimation(values: [1, 0.8, 1, 1, 1, 1],
                                                                    times: keyTimes,
                                                                    duration: duration)

            let groupAnimation = CAAnimation.groupAnimation(animations: [rotateAnimation, scaleAnimation], duration: duration, repeatCount: .infinity)

            Animation.animate(caAnimation: groupAnimation, layer: layer, key: "groupAnimation")

            blocks.forEach {
                $0.start()
            }

            CATransaction.commit()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            if animationState == .animation, layer.animation(forKey: "groupAnimation") == nil {
                _startAnimation()
            }
        }

        func stop() {
            guard animationState == .animation else {
                switch animationState {
                case .waitForRestart:
                    animationState = .stopAnimation
                default:
                    break
                }
                return
            }

            animationState = .stopAnimation

            let group = DispatchGroup()

            let completion: () -> Void = {
                group.leave()
            }

            CATransaction.begin()

            if let groupAnimation = layer.animation(forKey: "groupAnimation")?.copy() as? CAAnimation {
                groupAnimation.repeatCount = 1
                layer.removeAnimation(forKey: "groupAnimation")
                group.enter()
                Animation.animate(caAnimation: groupAnimation, layer: layer, key: "groupAnimation") { _ in
                    group.leave()
                    self.layer.removeAnimation(forKey: "groupAnimation")
                }
            }

            blocks.forEach {
                group.enter()
                $0.stop(completion: completion)
            }

            CATransaction.commit()

            group.notify(queue: .main) { [weak self] in
                guard let self = self else {return}

                switch self.animationState {
                case .waitForRestart:
                    self.animationState = .none
                    self.start()
                case .stopAnimation:
                    self.animationState = .none
                    self.isHidden = true
                default:
                    break
                }
            }
        }
    }
}
