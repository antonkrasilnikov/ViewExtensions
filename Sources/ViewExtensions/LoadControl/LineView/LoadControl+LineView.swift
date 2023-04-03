import Foundation
import UIKit

extension LoadControl {

    final class LineAnimatedView: View, LoadView {

        var color: UIColor? {
            didSet {
                blockLeft.backgroundColor = color
                blockCenter.backgroundColor = color
                blockRight.backgroundColor = color
            }
        }

        private enum _AnimationState {
            case none
            case animation
            case stopAnimation
            case waitForRestart
        }

        private var animationState: _AnimationState = .none

        private let blockLeft   = BlockEdgeView()
        private let blockCenter = BlockCenterView()
        private let blockRight  = BlockEdgeView()

        private let group = DispatchGroup()

        private let duration: TimeInterval = 1.6
        private let keyTimes: [NSNumber] = [0, 0.25, 0.5, 0.75, 1]

        override func setup() {
            super.setup()
            isHidden = true
            let moveValue: CGFloat = 4
            blockLeft.moveDistance = -moveValue
            blockRight.moveDistance = moveValue

            addSubview(blockLeft)
            blockLeft.duration = duration
            blockLeft.keyTimes = keyTimes

            addSubview(blockCenter)
            blockCenter.duration = duration

            addSubview(blockRight)
            blockRight.duration = duration
            blockRight.keyTimes = keyTimes
        }

        override func setupSizes() {
            super.setupSizes()

            let size: CGSize = Interface.sizeType == .pad ? .init(width: 10, height: 10) : .init(width: 6, height: 6)
            let spacing: CGFloat = Interface.sizeType == .pad ? 11 : 7
            let offset: CGFloat = size.height/2 + spacing

            blockLeft.autoSetDimensions(to: size)
            blockLeft.autoAlignAxis(toSuperviewAxis: .horizontal)
            blockLeft.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: -offset)

            blockCenter.autoSetDimensions(to: size)
            blockCenter.autoAlignAxis(toSuperviewAxis: .horizontal)
            blockCenter.autoAlignAxis(toSuperviewAxis: .vertical)

            blockRight.autoSetDimensions(to: size)
            blockRight.autoAlignAxis(toSuperviewAxis: .horizontal)
            blockRight.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: offset)
        }

        func start() {
            guard animationState == .none else {
                switch animationState {
                case .stopAnimation:
                    animationState = .waitForRestart
                case .animation:
                    if !blockLeft.isAnimating {
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

            blockLeft.start()
            blockCenter.start()
            blockRight.start()

            CATransaction.commit()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            if animationState == .animation, !blockLeft.isAnimating {
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

            group.enter()
            blockLeft.stop(completion: completion)

            group.enter()
            blockCenter.stop(completion: completion)

            group.enter()
            blockRight.stop(completion: completion)

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
