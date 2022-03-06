import Foundation
import UIKit
//@_exported import PureLayout

open class TableViewCellItem {
    public let reuseIdentifier: String
    public let cellType: AnyClass
    public var actionTypes: [AnyClass] = []
    
    public init(reuseIdentifier: String, cellType: AnyClass) {
        self.reuseIdentifier = reuseIdentifier
        self.cellType = cellType
    }
}

open class TableViewCell: UITableViewCell {
    open var item: TableViewCellItem?
    open var sizeSet = false
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupSizes()
    }
    
    open func setup() {
        
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !sizeSet {
            sizeSet = true
            setupSizes()
        }
    }
    
    open func setupSizes() {
        
    }
}

open class TableViewSection {
    public let items: [TableViewCellItem]
    public let number: Int
    
    public init(number: Int, items: [TableViewCellItem]) {
        self.number = number
        self.items = items
    }
}

public typealias TableViewCallback = (_ item: Any) -> Void
public typealias TableViewCellConfigCallback = (_ cell: TableViewCell) -> Void
public typealias TableViewHeaderSectionConfigCallback = (_ section: TableViewSection) -> UIView
public typealias TableViewFooterSectionConfigCallback = (_ section: TableViewSection) -> UIView
public typealias TableViewStartScrollCallback = () -> Void
public typealias TableViewStartDidScrollCallback = () -> Void
public typealias TableViewDragDidFinishScrollCallback = () -> Void
public typealias TableViewRowActionCallback = (_ item: TableViewCellItem, _ actionType: AnyClass) -> Void
public typealias TableViewWasReloadedCallback = () -> Void

open class TableView: UITableView,UITableViewDelegate,UITableViewDataSource {
    
    public var selectItemCallback: TableViewCallback?
    public var configCellCallback: TableViewCellConfigCallback?
    public var configSectionHeaderCallback: TableViewHeaderSectionConfigCallback?
    public var configSectionFooterCallback: TableViewFooterSectionConfigCallback?
    public var startScrollCallback: TableViewStartScrollCallback?
    public var scrollCallback: TableViewStartDidScrollCallback?
    public var dragFinishCallback: TableViewDragDidFinishScrollCallback?
    public var rowActionCallback: TableViewRowActionCallback?
    public var reloadCallback: TableViewWasReloadedCallback?
    
    public var registredCellIdentifiers: [String] = []
    
    public var sections: [TableViewSection] = [] {
        didSet {
            
            for section in self.sections {
                for item in section.items {
                    if !registredCellIdentifiers.contains(item.reuseIdentifier) {
                        self.register(item.cellType, forCellReuseIdentifier: item.reuseIdentifier)
                        registredCellIdentifiers.append(item.reuseIdentifier)
                    }
                }
            }
            
            _throttledReloadData()
        }
    }
    
    private var _nextPossibleReloadTS: TimeInterval = 0
    private var _reloadDelay: TimeInterval = 0.3
    
    @objc
    private func _throttledReloadData() {
        let currentTS = INCR_UISystemUptime.uptime()
        if currentTS >= _nextPossibleReloadTS {
            _nextPossibleReloadTS = currentTS + _reloadDelay
            reloadData()
        }else{
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_throttledReloadData), object: nil)
            perform(#selector(_throttledReloadData), with: nil, afterDelay: _nextPossibleReloadTS - currentTS)
        }
    }
    
    public var isKeyboardSizeSensitive = true
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public init(sections: [TableViewSection] = []) {
        super.init(frame: CGRect.zero, style: .plain)
        delegate = self
        dataSource = self
        estimatedRowHeight = 44.0
        rowHeight = UITableView.automaticDimension
        
        estimatedSectionHeaderHeight = 44.0
        sectionHeaderHeight = UITableView.automaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(_keyboardAppearanceWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_keyboardAppearanceWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.sections = sections
    }
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_throttledReloadData), object: nil)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_reloaded), object: nil)
    }
    
    open override func reloadData() {
        super.reloadData()
        perform(#selector(_reloaded), with: nil, afterDelay: 0)
    }
    
    @objc
    private func _reloaded() {
        reloadCallback?()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let handler = configSectionHeaderCallback {
            return handler(sections[section])
        }
        
        let view = UIView(frame: .zero)
        view.autoSetDimension(.height, toSize: 1)
        view.backgroundColor = .clear
        return view
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let handler = configSectionFooterCallback {
            return handler(sections[section])
        }

        let view = UIView(frame: .zero)
        view.autoSetDimension(.height, toSize: 1)
        view.backgroundColor = .clear
        return view
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
        
        if let cell = self.dequeueReusableCell(withIdentifier: item.reuseIdentifier) as? TableViewCell {
            cell.item = item
            if let configCellCallback = configCellCallback {
                configCellCallback(cell)
            }
            return cell
        }else{
            fatalError("cell is not registred")
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? TableViewCell
        if let item = cell?.item {
            selectItemCallback?(item)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startScrollCallback?()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dragFinishCallback?()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            dragFinishCallback?()
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell,
            let item = cell.item else { return [] }

        var rowActions: [UITableViewRowAction] = []

        for action in item.actionTypes {

            let rowAction = UITableViewRowAction(style: .default, title: "‎                             ‎‎‎‎‎‎‎‎") { [weak self] (rowAction, indexPath) in
                self?.rowActionCallback?(item, action)
            }

            if let viewType = action as? UIView.Type,
                let snapshot = viewType.init().snapshot() {
                rowAction.backgroundColor = UIColor(patternImage: snapshot)
            }

            rowActions.append(rowAction)
        }

        return rowActions
    }
}

extension TableView {
    @objc
    func _keyboardAppearanceWillChange(notification: Notification) {
        
        guard isKeyboardSizeSensitive,
            let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let window = self.window
            else { return }

        var h = bounds.height - convert(keyboardRect, from: window).origin.y
        
        h = h > 0 ? h : 0
                    
        self.setNeedsLayout()
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue(curve << 16)), animations: {
            self.layoutIfNeeded()
            self.contentInset.bottom = h
            self.scrollIndicatorInsets.bottom = h
            
        }) { (_) in

        }
        
    }
}
