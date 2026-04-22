# CoreAnimationKit

**CoreAnimationKit** is a lightweight utility library that simplifies working with Core Animation on iOS.

It provides:

- declarative keyframe animations
- animation grouping
- convenient helpers for common animations
- completion & start callbacks
- timeline-based animation orchestration

---

## ✨ Features

- Simple API for `CAKeyframeAnimation`
- Built-in animation types (scale, opacity, translation, rotation, etc.)
- Animation groups
- Keyframe-based timeline animations
- Completion & start handlers
- Delay support
- View-based animation helpers
- Support for path & stroke animations

---

## 🚀 Quick Start

### Basic animation

```swift
Animation.animate(
    caAnimation: CAAnimation.opacityAnimation(
        values: [0, 1],
        duration: 0.3
    ),
    layer: view.layer
)
```

## 🧩 Predefined Animations

### Opacity

```swift
CAAnimation.opacityAnimation(
    values: [0, 1],
    duration: 0.3
)
```

---

### Scale

```swift
CAAnimation.scaleAnimation(
    values: [0.8, 1.2, 1.0],
    duration: 0.4
)
```

---

### Translation

```swift
CAAnimation.traslateXAnimation(
    values: [-50, 0],
    duration: 0.3
)
```

---

### Rotation

```swift
CAAnimation.rotateAnimation(
    values: [0, .pi],
    duration: 0.5
)
```

---

## 🧱 Keyframe Model

```swift
CAAnimation.WBWKeyFrameAnimationModel(
    type: .scale,
    values: [0.8, 1.2, 1.0],
    times: [0, 0.5, 1.0]
)
```

Supported types:

- opacity
- scale / scaleX / scaleY
- translateX / translateY
- rotate / transform
- path / curve
- strokeColor
- lineWidth
- strokeEnd

---

## 🔗 Group Animations

```swift
let animation = CAAnimation.groupAnimation(
    with: [
        .init(type: .scale, values: [0.8, 1.0], times: [0, 1]),
        .init(type: .opacity, values: [0, 1], times: [0, 1])
    ],
    duration: 0.4
)

Animation.animate(
    caAnimation: animation,
    layer: view.layer
)
```

---

## 🎬 Animation with Callbacks

```swift
Animation.animate(
    caAnimation: animation,
    layer: view.layer,
    completionHandler: { finished in
        print("Completed:", finished)
    },
    startHandler: {
        print("Started")
    }
)
```

---

## ⏱ Delayed Animation

```swift
Animation.animate(
    caAnimation: animation,
    delay: 0.5,
    layer: view.layer
)
```

---

## 🎞 KeyFrameAnimation (Timeline API)

Provides a declarative way to compose complex animations.

### Example

```swift
KeyFrameAnimation.animate(withDuration: 1.0) {

    KeyFrameAnimation.addScaleAnimation(
        view: view,
        values: [0.5, 1.2, 1.0]
    )

    KeyFrameAnimation.addOpacityAnimation(
        view: view,
        values: [0, 1]
    )

    KeyFrameAnimation.addPerform(time: 0.5, over: view) {
        print("Halfway")
    }

}
```

---

## 🎯 Alignment-aware scaling

```swift
KeyFrameAnimation.addScaleYAnimation(
    view: view,
    values: [0, 1],
    align: .bottom
)
```

Supported:

- vertical: `.top`, `.center`, `.bottom`
- horizontal: `.left`, `.center`, `.right`

---

## 🧠 How It Works

- Wraps `CAKeyframeAnimation`
- Converts simple models into Core Animation keyPaths
- Uses `DispatchGroup` to track animation completion
- Provides timeline-style composition via static buffers

---

## ⚡ Advantages

- Much simpler than raw Core Animation
- Declarative animation building
- Reusable animation components
- Clean callback handling

---

## ⚠️ Notes

- Designed for UIKit (iOS)
- Uses Core Animation directly (not UIView animations)
- Be careful with layer state vs model state

---

## 💡 Use Cases

- UI transitions
- Micro-interactions
- Complex keyframe animations
- Custom loaders / indicators
- Game UI animations

---

## 📱 Platform

- iOS (UIKit + CoreAnimation)

---

## 📄 License

MIT
