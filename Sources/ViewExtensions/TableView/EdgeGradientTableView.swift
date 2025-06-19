//
//  EdgeGradientTableView.swift
//  wordByWord
//
//  Created by Антон Красильников on 10.06.2022.
//

import Foundation
import UIKit

open class EdgeGradientTableView: TableView {

    private let maskLayer = CAGradientLayer()

    public var percent: Float = 0.05 {
        didSet {
            setupMask()
        }
    }

    private let outerColor = UIColor(white: 1.0, alpha: 0.0).cgColor
    private let innerColor = UIColor(white: 1.0, alpha: 1.0).cgColor

    public override init(debounceDelay: TimeInterval = 0.3, sections: [TableViewSection]? = nil) {
        super.init(debounceDelay: debounceDelay, sections: sections)
        addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is EdgeGradientTableView && keyPath == "bounds" {
            setupMask()
        }
    }

    deinit {
        removeObserver(self, forKeyPath:"bounds")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateMask()
    }

    func setupMask() {

        maskLayer.locations = [0.0, NSNumber(value: percent), NSNumber(value:1 - percent), 1.0]
        maskLayer.bounds = CGRect(x:0, y:0, width:frame.size.width, height:frame.size.height)
        maskLayer.anchorPoint = CGPoint.zero
        self.layer.mask = maskLayer

        updateMask()
    }

    func updateMask() {
        let scrollView : UIScrollView = self

        var colors = [CGColor]()

        if scrollView.contentOffset.y <= -scrollView.contentInset.top {
            colors = [innerColor, innerColor, innerColor, outerColor]
        }else if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
            colors = [outerColor, innerColor, innerColor, innerColor]
        }else {
            colors = [outerColor, innerColor, innerColor, outerColor]
        }

        maskLayer.colors = colors

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        maskLayer.position = CGPoint(x: 0.0, y: scrollView.contentOffset.y)
        CATransaction.commit()
    }
}
