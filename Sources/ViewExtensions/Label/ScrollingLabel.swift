//
//  ScrollingLabel.swift
//
//  Created by Антон Красильников on 22.03.2021.
//  Copyright © 2021 Incrdbl Mbile Entertaiment. All rights reserved.
//

import Foundation
import UIKit

open class ScrollingLabelView: View, UIScrollViewDelegate {
    public let scrollView = UIScrollView()
    public let label = UILabel()
    private let shadowLayer = CAGradientLayer()
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    open override func setup() {
        addSubview(scrollView)
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.addSubview(label)
    }
    
    open override func setupSizes() {
        scrollView.autoPinEdgesToSuperviewEdges()
        label.autoPinEdgesToSuperviewEdges()
        label.autoMatch(.width, to: .width, of: self)
        label.autoMatch(.height, to: .height, of: self).priority = .init(UILayoutPriority.defaultHigh.rawValue - 1)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        _updateMask()
        perform(#selector(_updateMask), with: nil, afterDelay: 0.0)
    }
    
    @objc
    private func _updateMask() {
        shadowLayer.frame = bounds
        
        if scrollView.contentSize.height <= bounds.height {
            layer.mask = nil
        }else if scrollView.contentOffset.y <= 5 {
            if shadowLayer.locations != [0.0, 0.9, 1.0] {
                shadowLayer.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
                shadowLayer.locations = [0.0, 0.9, 1.0]
                layer.mask = shadowLayer
            }
        }else if scrollView.contentOffset.y + scrollView.bounds.height >= scrollView.contentSize.height - 5 {
            if shadowLayer.locations != [0.0, 0.1, 1.0] {
                shadowLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor]
                shadowLayer.locations = [0.0, 0.1, 1.0]
                layer.mask = shadowLayer
            }
        }else{
            if shadowLayer.locations != [0.0, 0.1, 0.9, 1.0] {
                shadowLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
                shadowLayer.locations = [0.0, 0.1, 0.9, 1.0]
                layer.mask = shadowLayer
            }
        }
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _updateMask()
    }
}
