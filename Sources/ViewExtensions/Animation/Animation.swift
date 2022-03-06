import Foundation
import UIKit
import QuartzCore

public extension CAAnimation {

    
    enum WBWAnimationType {
        case opacity
        case scale
        case translateX
        case translateY
        case rotate
        case transform
        case path
    }
    
    struct WBWKeyFrameAnimationModel {
        let type: WBWAnimationType
        let values: [Any]
        var times: [NSNumber]?
    }
    
    class func groupAnimation(with keyFrameModels: [WBWKeyFrameAnimationModel],
                        duration: TimeInterval,
                        repeatCount: Float = 1,
                        removeOnCompletion: Bool = false,
                        autoreverses: Bool = false,
                        timingFunction: CAMediaTimingFunctionName = .linear) -> CAAnimation {
        
        var animations: [CAAnimation] = []
        
        for model in keyFrameModels {
            animations.append(self.animation(with: model))
        }
        
        return self.groupAnimation(animations: animations, duration: duration, repeatCount: repeatCount, removeOnCompletion: removeOnCompletion,autoreverses: autoreverses, timingFunction: timingFunction)
    }
    
    class func groupAnimation(animations: [CAAnimation],
                        duration: TimeInterval,
                        repeatCount: Float = 1,
                        removeOnCompletion: Bool = false,
                        autoreverses: Bool = false,
                        timingFunction: CAMediaTimingFunctionName = .linear) -> CAAnimation {
        
        let animation = CAAnimationGroup()
        animation.duration = duration
        
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses
        
        if !removeOnCompletion {
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
        }
        
        animation.animations = animations
        return animation
    }
    
    private class func animation(with keyFrameModel: WBWKeyFrameAnimationModel) -> CAAnimation {
        
        var keyPath: String
        
        switch keyFrameModel.type {
        case .opacity:
            keyPath = "opacity"
        case .rotate,.transform:
            keyPath = "transform"
        case .translateX:
            keyPath = "transform.translation.x"
        case .translateY:
            keyPath = "transform.translation.y"
        case .scale:
            keyPath = "transform.scale"
        case .path:
            keyPath = "path"
        }
        
        let animation = CAKeyframeAnimation.init(keyPath: keyPath)
        animation.values = keyFrameModel.values
        animation.keyTimes = keyFrameModel.times
        return animation
    }
    
    class func opacityAnimation(values: [CGFloat],
                   times: [NSNumber]? = nil,
                   duration: TimeInterval,
                   repeatCount: Float = 1,
                   removeOnCompletion: Bool = false,
                   autoreverses: Bool = false,
                   timingFunction: CAMediaTimingFunctionName = .linear) -> CAAnimation {
        
        let model = WBWKeyFrameAnimationModel(type: .opacity, values: values, times: times)
        
        let animation = self.animation(with: model)
        animation.duration = duration
        
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses
        
        if !removeOnCompletion {
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
        }
        
        return animation
    }
    
    class func scaleAnimation(values: [CGFloat],
                   times: [NSNumber]? = nil,
                   duration: TimeInterval,
                   repeatCount: Float = 1,
                   removeOnCompletion: Bool = false,
                   autoreverses: Bool = false,
                   timingFunction: CAMediaTimingFunctionName = .linear) -> CAAnimation {
        
        let model = WBWKeyFrameAnimationModel(type: .scale, values: values, times: times)
        
        let animation = self.animation(with: model)
        animation.duration = duration
        
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses
        
        if !removeOnCompletion {
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
        }
        
        return animation
    }
    
    class func traslateXAnimation(values: [CGFloat],
                   times: [NSNumber]? = nil,
                   duration: TimeInterval,
                   repeatCount: Float = 1,
                   removeOnCompletion: Bool = false,
                   autoreverses: Bool = false,
                   timingFunction: CAMediaTimingFunctionName = .linear) -> CAAnimation {
        
        let model = WBWKeyFrameAnimationModel(type: .translateX, values: values, times: times)
        
        let animation = self.animation(with: model)
        animation.duration = duration
        
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses
        
        if !removeOnCompletion {
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
        }
        
        return animation
    }
    
    class func traslateYAnimation(values: [CGFloat],
                   times: [NSNumber]? = nil,
                   duration: TimeInterval,
                   repeatCount: Float = 1,
                   removeOnCompletion: Bool = false,
                   autoreverses: Bool = false,
                   timingFunction: CAMediaTimingFunctionName = .linear) -> CAAnimation {
        
        let model = WBWKeyFrameAnimationModel(type: .translateY, values: values, times: times)
        
        let animation = self.animation(with: model)
        animation.duration = duration
        
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses
        
        if !removeOnCompletion {
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
        }
        
        return animation
    }
    
    class func rotateAnimation(values: [CGFloat],
                   times: [NSNumber]? = nil,
                   duration: TimeInterval,
                   repeatCount: Float = 1,
                   removeOnCompletion: Bool = false,
                   autoreverses: Bool = false,
                   timingFunction: CAMediaTimingFunctionName = .linear) -> CAAnimation {
        
        var keyFrameValues: [CATransform3D] = []
        
        for angle in values {
            let transform = CATransform3DMakeRotation(angle, 0, 0, 1)
            keyFrameValues.append(transform)
        }

        let model = WBWKeyFrameAnimationModel(type: .rotate, values: keyFrameValues, times: times)
        
        let animation = self.animation(with: model)
        animation.duration = duration
        
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses
        
        if !removeOnCompletion {
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
        }
        
        return animation
    }
    
    class func transformAnimation(values: [CATransform3D],
                   times: [NSNumber]? = nil,
                   duration: TimeInterval,
                   repeatCount: Float = 1,
                   removeOnCompletion: Bool = false,
                   autoreverses: Bool = false,
                   timingFunction: CAMediaTimingFunctionName = .linear) -> CAAnimation {

        let model = WBWKeyFrameAnimationModel(type: .rotate, values: values, times: times)
        
        let animation = self.animation(with: model)
        animation.duration = duration
        
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses
        
        if !removeOnCompletion {
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
        }
        
        return animation
    }
    
    class func pathAnimation(values: [CGPath],
                   times: [NSNumber]? = nil,
                   duration: TimeInterval,
                   repeatCount: Float = 1,
                   removeOnCompletion: Bool = false,
                   autoreverses: Bool = false,
                   timingFunction: CAMediaTimingFunctionName = .linear) -> CAAnimation {

        let model = WBWKeyFrameAnimationModel(type: .path, values: values, times: times)
        
        let animation = self.animation(with: model)
        animation.duration = duration
        
        animation.timingFunction = CAMediaTimingFunction(name: timingFunction)
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses
        
        if !removeOnCompletion {
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
        }
        
        return animation
    }
}

public class Animation: NSObject,CAAnimationDelegate  {
    
    var completionHandler: ((Bool) -> Void)?
    var startHandler: (() -> Void)?
    
    private init(caAnimation: CAAnimation, layer: CALayer, key: String? = nil, completionHandler: ((Bool) -> Void)? = nil, startHandler: (() -> Void)? = nil) {
        
        super.init()
        
        self.completionHandler = completionHandler
        self.startHandler = startHandler
        
        caAnimation.delegate = self
        layer.add(caAnimation, forKey: key)
        
    }
    
    public class func animate(caAnimation: CAAnimation, layer: CALayer, key: String? = nil, completionHandler: ((Bool) -> Void)? = nil, startHandler: (() -> Void)? = nil) {
        _ = Animation.init(caAnimation: caAnimation, layer: layer, key: key, completionHandler: completionHandler, startHandler: startHandler)
    }
    
    public func animationDidStart(_ anim: CAAnimation) {
        if let startHandler = startHandler {
            self.startHandler = nil
            startHandler()
        }
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let completionHandler = completionHandler {
            self.completionHandler = nil
            completionHandler(flag)
        }
    }
}
