//
//  SelfSizingTableView.swift
//
//  Created by Павел Лунев on 02.03.2021.
//  Copyright © 2021 Incrdbl Mbile Entertaiment. All rights reserved.
//

import Foundation
import UIKit

open class SelfSizingTableView: TableView {

    private var _tableHeightConstraint: NSLayoutConstraint?

    public init() {
        super.init()
        _tableHeightConstraint = autoSetDimension(.height, toSize: 1)
        _tableHeightConstraint?.priority = .defaultLow
    }

    open override var sections: [TableViewSection] {
        didSet {
            _resizeTable()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        _resizeTable()
        self.perform(#selector(self._resizeTable), with: nil, afterDelay: 0)
    }

    @objc
    private func _resizeTable() {
        _tableHeightConstraint?.constant = contentSize.height == 0 ? 1 : contentSize.height
    }
}
