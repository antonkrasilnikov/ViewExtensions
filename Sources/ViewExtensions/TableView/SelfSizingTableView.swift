//
//  SelfSizingTableView.swift
//
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

    override func _reloaded() {
        super._reloaded()
        _resizeTable()
        setNeedsLayout()
        layoutIfNeeded()
    }
}
