import Foundation
import UIKit
import Timers


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
public typealias TableViewEditActionsWillAppearCallback = (_ item: TableViewCellItem) -> Void
public typealias TableViewWasReloadedCallback = () -> Void
public typealias TableViewEndScrollingAnimationCallback = () -> Void

open class TableView: UITableView,UITableViewDelegate,UITableViewDataSource {

    public var selectItemCallback: TableViewCallback?
    public var configCellCallback: TableViewCellConfigCallback?
    public var configSectionHeaderCallback: TableViewHeaderSectionConfigCallback?
    public var configSectionFooterCallback: TableViewFooterSectionConfigCallback?
    public var startScrollCallback: TableViewStartScrollCallback?
    public var scrollCallback: TableViewStartDidScrollCallback?
    public var dragFinishCallback: TableViewDragDidFinishScrollCallback?
    public var rowActionCallback: TableViewRowActionCallback?
    public var editActionsWillAppearCallback: TableViewEditActionsWillAppearCallback?
    public var reloadCallback: TableViewWasReloadedCallback?
    private var _endScrollingAnimationCallbacks: [TableViewEndScrollingAnimationCallback] = []

    var registredCellIdentifiers: [String] = []

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

    public func reload(with sections: [TableViewSection]) {
        _isReloadRequested = true
        self.sections = sections
    }

    public var selectionSound: ControlInteractionSound?

    private var _frizeSections: [TableViewSection] = []
    private var _nextPossibleReloadTS: TimeInterval = 0
    private var _reloadDelay: TimeInterval = 0.3
    private var _isReloadRequested = false

    @objc
    private func _throttledReloadData() {
        let currentTS = INC_SystemUptime.uptime()
        if currentTS >= _nextPossibleReloadTS {
            _nextPossibleReloadTS = currentTS + _reloadDelay

            let numberOfSections = numberOfSections

            if _isReloadRequested ||
               _frizeSections.isEmpty ||
                sections.isEmpty ||
                sections.count != numberOfSections ||
               Array(0..<numberOfSections).first(where: { sections[$0].items.count != numberOfRows(inSection: $0) }) != nil {
                _isReloadRequested = false
                _frizeSections = sections
                reloadData()
            }else{
                _frizeSections = sections
                if !_tryUpdateVisible() {
                    reloadData()
                }
            }

        }else{
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_throttledReloadData), object: nil)
            perform(#selector(_throttledReloadData), with: nil, afterDelay: _nextPossibleReloadTS - currentTS)
        }
    }

    private func _tryUpdateVisible() -> Bool {

        let isNeedReload: Bool

        let numberOfSections = self.numberOfSections

        if numberOfSections == _frizeSections.count,
           visibleCells.count <= _frizeSections.flatMap({$0.items}).count {
            isNeedReload = Array(0..<numberOfSections).first(where: { numberOfRows(inSection: $0) != _frizeSections[$0].items.count }) != nil
        }else{
            isNeedReload = true
        }

        if !isNeedReload {

            var reloadPaths: [IndexPath] = []
            var reconfigurePaths: [IndexPath] = []

            let preparedCellPaths = subviews.filter({cell in return cell is TableViewCell && visibleCells.contains(where: { $0 === cell }) == false}).compactMap({ indexPath(for: $0 as! TableViewCell) })

            ((indexPathsForVisibleRows ?? []) + preparedCellPaths).forEach { indexPath in
                let item = _frozenItem(at: indexPath)
                if item.reuseIdentifier == cellForRow(at: indexPath)?.reuseIdentifier {
                    reconfigurePaths.append(indexPath)
                }else{
                    reloadPaths.append(indexPath)
                }
            }

            guard reconfigurePaths.count + reloadPaths.count != 0 else {
                return false
            }
            if !reconfigurePaths.isEmpty {
                _reconfigureRows(at: reconfigurePaths)
            }

            if !reloadPaths.isEmpty {
                reloadRows(at: reloadPaths, with: .none)
            }

        }
        return !isNeedReload
    }

    private func _reconfigureRows(at indexPaths: [IndexPath]) {
        if #available(iOS 15.0, *) {
            reconfigureRows(at: indexPaths)
        }else{
            indexPaths.forEach { indexPath in
                (cellForRow(at: indexPath) as? TableViewCell)?.item = _frozenItem(at: indexPath)
            }
        }
    }

    private func _frozenItem(at indexPath: IndexPath) -> TableViewCellItem {
        let section = _frizeSections[indexPath.section]
        return section.items[indexPath.row]
    }

    var isKeyboardSizeSensitive = true

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

        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
            isPrefetchingEnabled = false
        }

        NotificationCenter.default.addObserver(self, selector: #selector(_keyboardAppearanceWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_keyboardAppearanceWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.sections = sections
    }

    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_throttledReloadData), object: nil)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_reloaded), object: nil)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_checkInitiatedScrollDidStop), object: nil)
    }

    open override func reloadData() {
        _frizeSections = sections
        super.reloadData()
        perform(#selector(_reloaded), with: nil, afterDelay: 0)
    }

    @objc
    private func _reloaded() {
        reloadCallback?()
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let handler = configSectionHeaderCallback {
            return handler(_frizeSections[section])
        }

        let view = UIView(frame: .zero)
        view.autoSetDimension(.height, toSize: 1)
        view.backgroundColor = .clear
        return view
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let handler = configSectionFooterCallback {
            return handler(_frizeSections[section])
        }

        let view = UIView(frame: .zero)
        view.autoSetDimension(.height, toSize: 1)
        view.backgroundColor = .clear
        return view
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return _frizeSections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _frizeSections[section].items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = _frozenItem(at: indexPath)

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
            if let selectItemCallback = selectItemCallback {
                selectionSound?.play()
                selectItemCallback(item)
            }
        }
    }

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startScrollCallback?()
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?()
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dragFinishCallback?()
    }

    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            dragFinishCallback?()
        }
    }

    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_checkInitiatedScrollDidStop), object: nil)
        _notifyScrollAnimationDidFinish()
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell,
            let item = cell.item else { return [] }

        editActionsWillAppearCallback?(item)

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

    private func _notifyScrollAnimationDidFinish() {
        guard !_endScrollingAnimationCallbacks.isEmpty else { return }
        let endScrollingAnimationCallbacks = _endScrollingAnimationCallbacks
        _endScrollingAnimationCallbacks.removeAll()
        endScrollingAnimationCallbacks.forEach({ $0() })
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

extension TableView {
    public func scrollAnimatedToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, completion: @escaping () -> Void) {
        _endScrollingAnimationCallbacks.append(completion)
        scrollToRow(at: indexPath, at: scrollPosition, animated: true)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_checkInitiatedScrollDidStop), object: nil)
        perform(#selector(_checkInitiatedScrollDidStop), with: nil, afterDelay: 0.5)
    }

    @objc
    private func _checkInitiatedScrollDidStop() {
        _notifyScrollAnimationDidFinish()
    }
}

