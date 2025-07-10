//
//  EdgeGradientCollectionView.swift
//  wordByWord
//
//  Created by Антон Красильников on 17.03.2023.
//  Copyright © 2023 Incrdbl Mobile Entertainment LLC. All rights reserved.
//

import Foundation
import UIKit

open class EdgeGradientCollectionView: CollectionView {

    public enum EdgeType {
        case mask
        case gradient(alpha: CGFloat)
    }

    private let maskLayer = CAGradientLayer()

    public var percent: Float = 0.05 {
        didSet {
            setupMask()
        }
    }

    public var edgeType: EdgeType = .mask {
        didSet {
            setupMask()
        }
    }

    private var isObserverAdded = false

    private var outerColor: CGColor {
        switch edgeType {
        case .mask:
            return UIColor(white: 1.0, alpha: 0.0).cgColor
        case .gradient(let alpha):
            guard let backgroundColor = backgroundColor else { return UIColor(white: 1.0, alpha: 0.0).cgColor }
            return backgroundColor.withAlphaComponent(alpha).cgColor
        }
    }

    private var innerColor: CGColor {
        switch edgeType {
        case .mask:
            return UIColor(white: 1.0, alpha: 1.0).cgColor
        case .gradient(_):
            guard let backgroundColor = backgroundColor else { return UIColor(white: 1.0, alpha: 0.0).cgColor }
            return backgroundColor.withAlphaComponent(0).cgColor
        }
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isObserverAdded else { return }
        isObserverAdded = true
        addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is EdgeGradientCollectionView && keyPath == "bounds" {
            setupMask()
        }
    }

    deinit {
        if isObserverAdded {
            removeObserver(self, forKeyPath:"bounds")
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateMask()
    }

    public override func setCollectionViewLayout(_ layout: UICollectionViewLayout, animated: Bool) {
        super.setCollectionViewLayout(layout, animated: animated)
        setupMask()
    }
    
    public override func setCollectionViewLayout(_ layout: UICollectionViewLayout, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        super.setCollectionViewLayout(layout, animated: animated, completion: completion)
        setupMask()
    }

    func setupMask() {

        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { self.layer.mask = nil; return }

        maskLayer.locations = [0.0, NSNumber(value: percent), NSNumber(value:1 - percent), 1.0]

        if layout.scrollDirection == .vertical {
            maskLayer.startPoint = .init(x: 0.5, y: 0)
            maskLayer.endPoint = .init(x: 0.5, y: 1)
        }else{
            maskLayer.startPoint = .init(x: 0, y: 0.5)
            maskLayer.endPoint = .init(x: 1, y: 0.5)
        }

        maskLayer.bounds = bounds
        maskLayer.anchorPoint = CGPoint.zero
        switch edgeType {
        case .mask:
            self.layer.mask = maskLayer
        case .gradient(_):
            layer.addSublayer(maskLayer)
        }

        updateMask()
    }

    func updateMask() {

        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { self.layer.mask = nil; return }

        let scrollView : UIScrollView = self

        var colors = [CGColor]()

        let offset: CGFloat
        let inset: CGFloat
        let frameSize: CGFloat
        let contentSize: CGFloat
        let position: CGPoint

        if layout.scrollDirection == .vertical {
            offset = scrollView.contentOffset.y
            inset = scrollView.contentInset.top
            frameSize = scrollView.frame.size.height
            contentSize = scrollView.contentSize.height
            position = CGPoint(x: 0.0, y: scrollView.contentOffset.y)
        }else{
            offset = scrollView.contentOffset.x
            inset = scrollView.contentInset.left
            frameSize = scrollView.frame.size.width
            contentSize = scrollView.contentSize.width
            position = CGPoint(x: scrollView.contentOffset.x, y: 0.0)
        }

        if offset <= -inset {
            colors = [innerColor, innerColor, innerColor, outerColor]
        }else if offset + frameSize >= contentSize {
            colors = [outerColor, innerColor, innerColor, innerColor]
        }else {
            colors = [outerColor, innerColor, innerColor, outerColor]
        }

        maskLayer.colors = colors

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        maskLayer.position = position
        CATransaction.commit()
    }
}
