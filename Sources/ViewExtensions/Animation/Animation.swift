import Foundation
import UIKit
import QuartzCore

public extension CAAnimation {

    enum WBWAnimationType {
        case opacity
        case scale
        case scaleX
        case scaleY
        case translateX
        case translateY
        case rotate
        case transform
        case path
        case strokeColor
        case lineWidth
        case strokeEnd
    }

    struct WBWKeyFrameAnimationModel {
        public let type: WBWAnimationType
        public let values: [Any]
        public var times: [NSNumber]?
        public var timingFunctions: [CAMediaTimingFunction]?
        public var calculationMode: CAAnimationCalculationMode


        public init(type: WBWAnimationType, values: [Any], times: [NSNumber]?, timingFunctions: [CAMediaTimingFunction]? = nil, calculationMode: CAAnimationCalculationMode = .linear) {
            self.type = type
            self.values = values
            self.times = times
            self.timingFunctions = timingFunctions
            self.calculationMode = calculationMode
        }

        public init(type: WBWAnimationType, values: [Any], times: [TimeInterval]?, timingFunctions: [CAMediaTimingFunction]? = nil, calculationMode: CAAnimationCalculationMode = .linear) {
            self.type = type
            self.values = values
            self.times = times?.compactMap({ NSNumber(value: $0) })
            self.timingFunctions = timingFunctions
            self.calculationMode = calculationMode
        }
    }

    class func groupAnimation(with keyFrameModels: [WBWKeyFrameAnimationModel],
                        duration: TimeInterval,
                        repeatCount: Float = 1,
                        removeOnCompletion: Bool = false,
                        autoreverses: Bool = false,
                        timingFunctionName: CAMediaTimingFunctionName? = nil) -> CAAnimation {

        var animations: [CAAnimation] = []

        for model in keyFrameModels {
            animations.append(self.animation(with: model))
        }

        return self.groupAnimation(animations: animations, duration: duration, repeatCount: repeatCount, removeOnCompletion: removeOnCompletion,autoreverses: autoreverses, timingFunctionName: timingFunctionName)
    }

    class func groupAnimation(animations: [CAAnimation],
                        duration: TimeInterval,
                        repeatCount: Float = 1,
                        removeOnCompletion: Bool = false,
                        autoreverses: Bool = false,
                        timingFunctionName: CAMediaTimingFunctionName? = nil) -> CAAnimation {

        let animation = CAAnimationGroup()
        animation.duration = duration

        if let timingFunctionName = timingFunctionName {
            animation.timingFunction = CAMediaTimingFunction(name: timingFunctionName)
        }
        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses

        if !removeOnCompletion {
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
        }

        animation.animations = animations
        return animation
    }

    private class func animation(with keyFrameModel: WBWKeyFrameAnimationModel) -> CAKeyframeAnimation {

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
        case .scaleX:
            keyPath = "transform.scale.x"
        case .scaleY:
            keyPath = "transform.scale.y"
        case .path:
            keyPath = "path"
        case .strokeColor:
            keyPath = "strokeColor"
        case .lineWidth:
            keyPath = "lineWidth"
        case .strokeEnd:
            keyPath = "strokeEnd"
        }

        let animation = CAKeyframeAnimation.init(keyPath: keyPath)
        animation.values = keyFrameModel.values
        animation.keyTimes = keyFrameModel.times
        animation.timingFunctions = keyFrameModel.timingFunctions
        animation.calculationMode = keyFrameModel.calculationMode
        return animation
    }

    fileprivate class func animation(with model: WBWKeyFrameAnimationModel,
                                 duration: TimeInterval,
                                 repeatCount: Float = 1,
                                 removeOnCompletion: Bool = false,
                                 autoreverses: Bool = false,
                                 timingFunctionName: CAMediaTimingFunctionName? = nil,
                                 timingFunctions: [CAMediaTimingFunction]? = nil) -> CAAnimation {

        let animation = self.animation(with: model)
        animation.duration = duration

        if let timingFunctions = timingFunctions {
            animation.timingFunctions = timingFunctions
        }else if let timingFunctionName = timingFunctionName {
            animation.timingFunction = CAMediaTimingFunction(name: timingFunctionName)
        }

        animation.repeatCount = repeatCount
        animation.autoreverses = autoreverses

        if !removeOnCompletion {
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
        }

        return animation
    }

    class func opacityAnimation(values: [CGFloat],
                                times: [NSNumber]? = nil,
                                duration: TimeInterval,
                                repeatCount: Float = 1,
                                removeOnCompletion: Bool = false,
                                autoreverses: Bool = false,
                                timingFunctionName: CAMediaTimingFunctionName? = nil,
                                timingFunctions: [CAMediaTimingFunction]? = nil) -> CAAnimation {
        animation(with: WBWKeyFrameAnimationModel(type: .opacity, values: values, times: times),
                  duration: duration,
                  repeatCount: repeatCount,
                  removeOnCompletion: removeOnCompletion,
                  autoreverses: autoreverses,
                  timingFunctionName: timingFunctionName,
                  timingFunctions: timingFunctions)
    }

    class func scaleAnimation(values: [CGFloat],
                              times: [NSNumber]? = nil,
                              duration: TimeInterval,
                              repeatCount: Float = 1,
                              removeOnCompletion: Bool = false,
                              autoreverses: Bool = false,
                              timingFunctionName: CAMediaTimingFunctionName = .linear,
                              timingFunctions: [CAMediaTimingFunction]? = nil) -> CAAnimation {
        animation(with: WBWKeyFrameAnimationModel(type: .scale, values: values, times: times),
                  duration: duration,
                  repeatCount: repeatCount,
                  removeOnCompletion: removeOnCompletion,
                  autoreverses: autoreverses,
                  timingFunctionName: timingFunctionName,
                  timingFunctions: timingFunctions)
    }

    class func traslateXAnimation(values: [CGFloat],
                                  times: [NSNumber]? = nil,
                                  duration: TimeInterval,
                                  repeatCount: Float = 1,
                                  removeOnCompletion: Bool = false,
                                  autoreverses: Bool = false,
                                  timingFunctionName: CAMediaTimingFunctionName? = nil,
                                  timingFunctions: [CAMediaTimingFunction]? = nil) -> CAAnimation {
        animation(with: WBWKeyFrameAnimationModel(type: .translateX, values: values, times: times),
                  duration: duration,
                  repeatCount: repeatCount,
                  removeOnCompletion: removeOnCompletion,
                  autoreverses: autoreverses,
                  timingFunctionName: timingFunctionName,
                  timingFunctions: timingFunctions)
    }

    class func traslateYAnimation(values: [CGFloat],
                                  times: [NSNumber]? = nil,
                                  duration: TimeInterval,
                                  repeatCount: Float = 1,
                                  removeOnCompletion: Bool = false,
                                  autoreverses: Bool = false,
                                  timingFunctionName: CAMediaTimingFunctionName? = nil,
                                  timingFunctions: [CAMediaTimingFunction]? = nil) -> CAAnimation {
        animation(with: WBWKeyFrameAnimationModel(type: .translateY, values: values, times: times),
                  duration: duration,
                  repeatCount: repeatCount,
                  removeOnCompletion: removeOnCompletion,
                  autoreverses: autoreverses,
                  timingFunctionName: timingFunctionName,
                  timingFunctions: timingFunctions)
    }

    class func rotateAnimation(values: [CGFloat],
                               times: [NSNumber]? = nil,
                               duration: TimeInterval,
                               repeatCount: Float = 1,
                               removeOnCompletion: Bool = false,
                               autoreverses: Bool = false,
                               timingFunctionName: CAMediaTimingFunctionName? = nil,
                               timingFunctions: [CAMediaTimingFunction]? = nil) -> CAAnimation {
        animation(with: WBWKeyFrameAnimationModel(type: .rotate, values: values.compactMap({ CATransform3DMakeRotation($0, 0, 0, 1) }), times: times),
                  duration: duration,
                  repeatCount: repeatCount,
                  removeOnCompletion: removeOnCompletion,
                  autoreverses: autoreverses,
                  timingFunctionName: timingFunctionName,
                  timingFunctions: timingFunctions)
    }

    class func transformAnimation(values: [CATransform3D],
                                  times: [NSNumber]? = nil,
                                  duration: TimeInterval,
                                  repeatCount: Float = 1,
                                  removeOnCompletion: Bool = false,
                                  autoreverses: Bool = false,
                                  timingFunctionName: CAMediaTimingFunctionName? = nil,
                                  timingFunctions: [CAMediaTimingFunction]? = nil) -> CAAnimation {
        animation(with: WBWKeyFrameAnimationModel(type: .transform, values: values, times: times),
                  duration: duration,
                  repeatCount: repeatCount,
                  removeOnCompletion: removeOnCompletion,
                  autoreverses: autoreverses,
                  timingFunctionName: timingFunctionName,
                  timingFunctions: timingFunctions)
    }

    class func pathAnimation(values: [CGPath],
                             times: [NSNumber]? = nil,
                             duration: TimeInterval,
                             repeatCount: Float = 1,
                             removeOnCompletion: Bool = false,
                             autoreverses: Bool = false,
                             timingFunctionName: CAMediaTimingFunctionName? = nil,
                             timingFunctions: [CAMediaTimingFunction]? = nil) -> CAAnimation {
        animation(with: WBWKeyFrameAnimationModel(type: .path, values: values, times: times),
                  duration: duration,
                  repeatCount: repeatCount,
                  removeOnCompletion: removeOnCompletion,
                  autoreverses: autoreverses,
                  timingFunctionName: timingFunctionName,
                  timingFunctions: timingFunctions)
    }

    class func strokeColorAnimation(values: [CGColor],
                               times: [NSNumber]? = nil,
                               duration: TimeInterval,
                               repeatCount: Float = 1,
                               removeOnCompletion: Bool = false,
                               autoreverses: Bool = false,
                               timingFunctionName: CAMediaTimingFunctionName? = nil,
                               timingFunctions: [CAMediaTimingFunction]? = nil) -> CAAnimation {
        animation(with: WBWKeyFrameAnimationModel(type: .strokeColor, values: values, times: times),
                  duration: duration,
                  repeatCount: repeatCount,
                  removeOnCompletion: removeOnCompletion,
                  autoreverses: autoreverses,
                  timingFunctionName: timingFunctionName,
                  timingFunctions: timingFunctions)
    }
}

open class Animation: NSObject,CAAnimationDelegate  {

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

    public class func animate(keyFrames: [CAAnimation.WBWKeyFrameAnimationModel], duration: TimeInterval, layer: CALayer, key: String? = nil, completionHandler: ((Bool) -> Void)? = nil, startHandler: (() -> Void)? = nil) {
        _ = Animation.init(caAnimation: CAAnimation.groupAnimation(with: keyFrames, duration: duration), layer: layer, key: key, completionHandler: completionHandler, startHandler: startHandler)
    }

    public class func animate(keyFrame: CAAnimation.WBWKeyFrameAnimationModel, duration: TimeInterval, layer: CALayer, key: String? = nil, completionHandler: ((Bool) -> Void)? = nil, startHandler: (() -> Void)? = nil) {
        _ = Animation.init(caAnimation: CAAnimation.animation(with: keyFrame, duration: duration), layer: layer, key: key, completionHandler: completionHandler, startHandler: startHandler)
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

public class KeyFrameAnimation: NSObject {

    public enum VerticalAlign {
        case center
        case top
        case bottom
    }

    public enum HorizontalAlign {
        case center
        case left
        case right
    }

    private struct KeyFrame {
        let layer: CALayer
        let model: CAAnimation.WBWKeyFrameAnimationModel
    }

    private struct KeyframeTimePerform {
        let time: TimeInterval
        let action: () -> Void
        let syncView: UIView
    }

    private var completionHandler: ((Bool) -> Void)?
    private var keyFrames: [KeyFrame]
    private var keyFramePerforms: [KeyframeTimePerform]
    private static var keyFramesBuffer: [KeyFrame] = []
    private static var keyFramesPerformsBuffer: [KeyframeTimePerform] = []
    private var group = DispatchGroup()
    private var animationCompleteFlag = true

    private init(withDuration duration: TimeInterval, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {

        self.completionHandler = completion

        Self.keyFramesBuffer.removeAll()
        Self.keyFramesPerformsBuffer.removeAll()

        animations()

        self.keyFrames = Self.keyFramesBuffer
        self.keyFramePerforms = Self.keyFramesPerformsBuffer

        Self.keyFramesBuffer.removeAll()
        Self.keyFramesPerformsBuffer.removeAll()

        super.init()

        var performViews: [UIView] = []

        CATransaction.begin()

        keyFrames.forEach { keyFrame in
            group.enter()
            Animation.animate(keyFrame: keyFrame.model, duration: duration, layer: keyFrame.layer, completionHandler: { flag in
                self.animationCompleteFlag = self.animationCompleteFlag && flag
                self.group.leave()
            })
        }

        keyFramePerforms.forEach { perform in
            group.enter()

            Animation.animate(caAnimation: .opacityAnimation(values: [0,1], duration: perform.time*duration),
                              layer: {
                $0.frame = .init(origin: .zero, size: .init(width: 1, height: 1))
                $0.isUserInteractionEnabled = false
                perform.syncView.addSubview($0)
                performViews.append($0)
                return $0
            }(UIView()).layer) { _ in
                perform.action()
                self.group.leave()
            }
        }

        CATransaction.commit()

        group.notify(queue: .main) {
            performViews.forEach({ $0.removeFromSuperview() })
            if let completionHandler = self.completionHandler {
                self.completionHandler = nil
                completionHandler(self.animationCompleteFlag)
            }
        }

    }

    private class func scaleYTransforms(view: UIView, values: [CGFloat], align: VerticalAlign) -> [CATransform3D] {
        let h = view.frame.size.height
        let sign: CGFloat
        switch align {
        case .center:
            sign = 0
        case .bottom:
            sign = 1
        case .top:
            sign = -1
        }
        return values.compactMap {
            CATransform3DScale(CATransform3DMakeTranslation(0, sign*(1-$0)*0.5*h, 0), 1, $0, 1)
        }
    }

    private class func scaleXTransforms(view: UIView, values: [CGFloat], align: HorizontalAlign) -> [CATransform3D] {
        let w = view.frame.size.width
        let sign: CGFloat
        switch align {
        case .center:
            sign = 0
        case .right:
            sign = 1
        case .left:
            sign = -1
        }
        return values.compactMap {
            CATransform3DScale(CATransform3DMakeTranslation(sign*(1-$0)*0.5*w, 0, 0), $0, 1, 1)
        }
    }

    public class func animate(withDuration duration: TimeInterval, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        _ = KeyFrameAnimation(withDuration: duration, animations: animations, completion: completion)
    }

    private class func timeFunctions(timingFunctionName: CAMediaTimingFunctionName?, timingFunctions: [CAMediaTimingFunction]?) -> [CAMediaTimingFunction]? {
        timingFunctions ?? ( timingFunctionName != nil ? [.init(name: timingFunctionName!)] : nil)
    }

    public class func addOpacityAnimation(view: UIView,
                                   values: [CGFloat],
                                   times: [TimeInterval]? = nil,
                                   timingFunctionName: CAMediaTimingFunctionName? = nil,
                                   timingFunctions: [CAMediaTimingFunction]? = nil) {
        Self.keyFramesBuffer.append(.init(layer: view.layer,
                                          model: CAAnimation.WBWKeyFrameAnimationModel(type: .opacity,
                                                                                       values: values,
                                                                                       times: times,
                                                                                       timingFunctions: timeFunctions(timingFunctionName: timingFunctionName,
                                                                                                                      timingFunctions: timingFunctions))))
    }

    public class func addScaleAnimation(view: UIView,
                                 values: [CGFloat],
                                 times: [TimeInterval]? = nil,
                                 timingFunctionName: CAMediaTimingFunctionName? = nil,
                                 timingFunctions: [CAMediaTimingFunction]? = nil) {
        Self.keyFramesBuffer.append(.init(layer: view.layer,
                                          model: CAAnimation.WBWKeyFrameAnimationModel(type: .scale,
                                                                                       values: values,
                                                                                       times: times,
                                                                                       timingFunctions: timeFunctions(timingFunctionName: timingFunctionName,
                                                                                                                      timingFunctions: timingFunctions))))
    }

    public class func addScaleXAnimation(view: UIView,
                                 values: [CGFloat],
                                 times: [TimeInterval]? = nil,
                                 align: HorizontalAlign = .center,
                                 timingFunctionName: CAMediaTimingFunctionName? = nil,
                                 timingFunctions: [CAMediaTimingFunction]? = nil) {
        Self.addTransformAnimation(view: view,
                                   values: Self.scaleXTransforms(view: view, values: values, align: align),
                                   times: times,
                                   timingFunctionName: timingFunctionName,
                                   timingFunctions: timingFunctions)
    }

    public class func addScaleYAnimation(view: UIView,
                                 values: [CGFloat],
                                 times: [TimeInterval]? = nil,
                                 align: VerticalAlign = .center,
                                 timingFunctionName: CAMediaTimingFunctionName? = nil,
                                  timingFunctions: [CAMediaTimingFunction]? = nil) {
        Self.addTransformAnimation(view: view,
                                   values: Self.scaleYTransforms(view: view, values: values, align: align),
                                   times: times,
                                   timingFunctionName: timingFunctionName,
                                   timingFunctions: timingFunctions)
    }

    public class func addTranslateXAnimation(view: UIView,
                                      values: [CGFloat],
                                      times: [TimeInterval]? = nil,
                                      timingFunctionName: CAMediaTimingFunctionName? = nil,
                                      timingFunctions: [CAMediaTimingFunction]? = nil) {
        Self.keyFramesBuffer.append(.init(layer: view.layer,
                                          model: CAAnimation.WBWKeyFrameAnimationModel(type: .translateX,
                                                                                       values: values,
                                                                                       times: times,
                                                                                       timingFunctions: timeFunctions(timingFunctionName: timingFunctionName,
                                                                                                                      timingFunctions: timingFunctions))))
    }

    public class func addTranslateYAnimation(view: UIView,
                                      values: [CGFloat],
                                      times: [TimeInterval]? = nil,
                                      timingFunctionName: CAMediaTimingFunctionName? = nil,
                                      timingFunctions: [CAMediaTimingFunction]? = nil) {
        Self.keyFramesBuffer.append(.init(layer: view.layer,
                                          model: CAAnimation.WBWKeyFrameAnimationModel(type: .translateY,
                                                                                       values: values,
                                                                                       times: times,
                                                                                       timingFunctions: timeFunctions(timingFunctionName: timingFunctionName,
                                                                                                                      timingFunctions: timingFunctions))))
    }

    public class func addRotateAnimation(view: UIView,
                                  values: [CGFloat],
                                  times: [TimeInterval]? = nil,
                                  timingFunctionName: CAMediaTimingFunctionName? = nil,
                                  timingFunctions: [CAMediaTimingFunction]? = nil) {
        Self.keyFramesBuffer.append(.init(layer: view.layer,
                                          model: CAAnimation.WBWKeyFrameAnimationModel(type: .rotate,
                                                                                       values: values.compactMap({ CATransform3DMakeRotation($0, 0, 0, 1) }),
                                                                                       times: times,
                                                                                       timingFunctions: timeFunctions(timingFunctionName: timingFunctionName,
                                                                                                                      timingFunctions: timingFunctions))))
    }

    public class func addTransformAnimation(view: UIView,
                                     values: [CATransform3D],
                                     times: [TimeInterval]? = nil,
                                     timingFunctionName: CAMediaTimingFunctionName? = nil,
                                     timingFunctions: [CAMediaTimingFunction]? = nil) {
        Self.keyFramesBuffer.append(.init(layer: view.layer,
                                          model: CAAnimation.WBWKeyFrameAnimationModel(type: .transform,
                                                                                       values: values,
                                                                                       times: times,
                                                                                       timingFunctions: timeFunctions(timingFunctionName: timingFunctionName,
                                                                                                                      timingFunctions: timingFunctions))))
    }

    public class func addPathAnimation(view: UIView,
                                values: [CGPath],
                                times: [TimeInterval]? = nil,
                                timingFunctionName: CAMediaTimingFunctionName? = nil,
                                timingFunctions: [CAMediaTimingFunction]? = nil) {
        addPathAnimation(layer: view.layer, values: values, times: times, timingFunctionName: timingFunctionName, timingFunctions: timingFunctions)
    }

    public class func addPathAnimation(layer: CALayer,
                                values: [CGPath],
                                times: [TimeInterval]? = nil,
                                timingFunctionName: CAMediaTimingFunctionName? = nil,
                                timingFunctions: [CAMediaTimingFunction]? = nil) {
        Self.keyFramesBuffer.append(.init(layer: layer,
                                          model: CAAnimation
            .WBWKeyFrameAnimationModel(type: .path,
                                       values: values,
                                       times: times,
                                       timingFunctions: timeFunctions(timingFunctionName: timingFunctionName,
                                                                      timingFunctions: timingFunctions))))
    }

    public class func addStrokeColorAnimation(view: UIView,
                                     values: [CGColor],
                                     times: [TimeInterval]? = nil,
                                     timingFunctionName: CAMediaTimingFunctionName? = nil,
                                     timingFunctions: [CAMediaTimingFunction]? = nil) {
        addStrokeColorAnimation(layer: view.layer, values: values, times: times, timingFunctionName: timingFunctionName, timingFunctions: timingFunctions)
    }

    public class func addStrokeColorAnimation(layer: CALayer,
                                     values: [CGColor],
                                     times: [TimeInterval]? = nil,
                                     timingFunctionName: CAMediaTimingFunctionName? = nil,
                                     timingFunctions: [CAMediaTimingFunction]? = nil) {
        Self.keyFramesBuffer.append(.init(layer: layer,
                                          model: CAAnimation
            .WBWKeyFrameAnimationModel(type: .strokeColor,
                                       values: values,
                                       times: times,
                                       timingFunctions: timeFunctions(timingFunctionName: timingFunctionName,
                                                                      timingFunctions: timingFunctions))))
    }

    public class func addLineWidthAnimation(view: UIView,
                                     values: [CGFloat],
                                     times: [TimeInterval]? = nil,
                                     timingFunctionName: CAMediaTimingFunctionName? = nil,
                                     timingFunctions: [CAMediaTimingFunction]? = nil) {
        addLineWidthAnimation(layer: view.layer, values: values, times: times, timingFunctionName: timingFunctionName, timingFunctions: timingFunctions)
    }

    public class func addLineWidthAnimation(layer: CALayer,
                                     values: [CGFloat],
                                     times: [TimeInterval]? = nil,
                                     timingFunctionName: CAMediaTimingFunctionName? = nil,
                                     timingFunctions: [CAMediaTimingFunction]? = nil) {
        Self.keyFramesBuffer.append(.init(layer: layer,
                                          model: CAAnimation
            .WBWKeyFrameAnimationModel(type: .lineWidth,
                                       values: values,
                                       times: times,
                                       timingFunctions: timeFunctions(timingFunctionName: timingFunctionName,
                                                                      timingFunctions: timingFunctions))))
    }

    public class func addStrokeEndAnimation(view: UIView,
                                     values: [CGFloat],
                                     times: [TimeInterval]? = nil,
                                     timingFunctionName: CAMediaTimingFunctionName? = nil,
                                     timingFunctions: [CAMediaTimingFunction]? = nil) {
        addStrokeEndAnimation(layer: view.layer, values: values, times: times, timingFunctionName: timingFunctionName, timingFunctions: timingFunctions)
    }

    public class func addStrokeEndAnimation(layer: CALayer,
                                     values: [CGFloat],
                                     times: [TimeInterval]? = nil,
                                     timingFunctionName: CAMediaTimingFunctionName? = nil,
                                     timingFunctions: [CAMediaTimingFunction]? = nil) {
        Self.keyFramesBuffer.append(.init(layer: layer,
                                          model: CAAnimation
            .WBWKeyFrameAnimationModel(type: .strokeEnd,
                                       values: values,
                                       times: times,
                                       timingFunctions: timeFunctions(timingFunctionName: timingFunctionName,
                                                                      timingFunctions: timingFunctions))))
    }

    public class func addPerform(time: TimeInterval, over view: UIView, action: @escaping () -> Void) {
        Self.keyFramesPerformsBuffer.append(.init(time: time, action: action, syncView: view))
    }
}
