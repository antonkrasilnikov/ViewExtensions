import Foundation
import UIKit
import Timers
import AsyncOperation

// MARK: public interface
public typealias TableViewCallback = (_ item: Any) -> Void
public typealias TableViewCellConfigCallback = (_ cell: TableViewCell) -> Void
public typealias TableViewHeaderSectionConfigCallback = (_ section: TableViewSection) -> UIView
public typealias TableViewFooterSectionConfigCallback = (_ section: TableViewSection) -> UIView
public typealias TableViewStartScrollCallback = () -> Void
public typealias TableViewStartDidScrollCallback = () -> Void
public typealias TableViewDragDidFinishScrollCallback = () -> Void
public typealias TableViewRowActionCallback = (_ item: TableViewCellItem, _ actionType: AnyClass) -> Void
public typealias TableViewWasReloadedCallback = () -> Void
public typealias TableViewEndScrollingAnimationCallback = () -> Void
public typealias TableViewRowEditActionCallback = (_ item: TableViewCellItem, _ indexPath: IndexPath, _ editType: UITableViewCell.EditingStyle) -> Void

public protocol TableViewInterface: NSObjectProtocol {
    var selectItemCallback: TableViewCallback? { set get }
    var configCellCallback: TableViewCellConfigCallback? { set get }
    var startScrollCallback: TableViewStartScrollCallback? { set get }
    var scrollCallback: TableViewStartDidScrollCallback? { set get }
    var dragFinishCallback: TableViewDragDidFinishScrollCallback? { set get }
    var rowActionCallback: TableViewRowActionCallback? { set get }
    var reloadCallback: TableViewWasReloadedCallback? { set get }
    var editCallback: TableViewRowEditActionCallback? { set get }
    var sections: [TableViewSection] { get }
    var selectionSound: ControlInteractionSound? { set get }
    var isKeyboardSizeSensitive: Bool { set get }

    func set(sections: [TableViewSection], completion: (() -> Void)?)
    func reload(with sections: [TableViewSection], completion: (() -> Void)?)
    func scrollAnimatedToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, completion: @escaping () -> Void)
}

public protocol TableViewEditInterface: NSObjectProtocol {
    func deleteRows(indexPaths: [IndexPath], with animation: UITableView.RowAnimation, completion: @escaping (Bool) -> Void)
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath, completion: @escaping (Bool) -> Void)
    func insert(items: [TableRawEditEntity], with animation: UITableView.RowAnimation, completion: @escaping (Bool) -> Void)
    func reload(items: [TableRawEditEntity], with animation: UITableView.RowAnimation, completion: @escaping (Bool) -> Void)
    func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation, completion: @escaping (Bool) -> Void)
    func insertSections(_ sections: [TableSectionEditEntity], with animation: UITableView.RowAnimation, completion: @escaping (Bool) -> Void)
}

// MARK: public models
public struct TableSectionEditEntity {
    public let index: Int
    public let section: TableViewSection
    
    public init(index: Int, section: TableViewSection) {
        self.index = index
        self.section = section
    }
}

public struct TableRawEditEntity {
    public let indexPath: IndexPath
    public let item: TableViewCellItem

    public init(indexPath: IndexPath, item: TableViewCellItem) {
        self.indexPath = indexPath
        self.item = item
    }
}

open class TableSupplementaryItem {
    public let reuseIdentifier: String
    public let viewType: AnyClass
    public let height: CGFloat

    public init(reuseIdentifier: String, viewType: AnyClass, height: CGFloat) {
        self.reuseIdentifier = reuseIdentifier
        self.viewType = viewType
        self.height = height
    }
}

open class TableSupplementaryView: UITableViewHeaderFooterView {
    open var item: TableSupplementaryItem?
    open var sizeSet = false

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard !sizeSet else { return }
        sizeSet = true
        setupSizes()
    }

    open func setupSizes() {}
    open func setup() {}
}

open class TableViewCellItem {
    public let reuseIdentifier: String
    public let cellType: AnyClass
    public var leadingActions: [UIContextualAction] = []
    public var trailingingActions: [UIContextualAction] = []
    public var editingStyle: UITableViewCell.EditingStyle = .none

    public var isEditable: Bool {
        editingStyle != .none || !leadingActions.isEmpty || !trailingingActions.isEmpty
    }

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

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard !sizeSet else { return }
        sizeSet = true
        setupSizes()
    }

    open func setup() {}
    open func setupSizes() {}
}

open class TableViewSection {
    public let headerItem: TableSupplementaryItem?
    public let footerItem: TableSupplementaryItem?
    public let items: [TableViewCellItem]
    public let number: Int

    public init(number: Int, items: [TableViewCellItem], headerItem: TableSupplementaryItem? = nil, footerItem: TableSupplementaryItem? = nil) {
        self.number = number
        self.items = items
        self.headerItem = headerItem
        self.footerItem = footerItem
    }

    public func copy(number: Int? = nil, items: [TableViewCellItem]? = nil, headerItem: TableSupplementaryItem? = nil, footerItem: TableSupplementaryItem? = nil) -> TableViewSection {
        .init(number: number ?? self.number,
              items: items ?? self.items,
              headerItem: headerItem ?? self.headerItem,
              footerItem: footerItem ?? self.footerItem)
    }
}

// MARK: implementation
open class TableView: UITableView,UITableViewDelegate,UITableViewDataSource,TableViewInterface {

    public var selectItemCallback: TableViewCallback?
    public var configCellCallback: TableViewCellConfigCallback?
    public var startScrollCallback: TableViewStartScrollCallback?
    public var scrollCallback: TableViewStartDidScrollCallback?
    public var dragFinishCallback: TableViewDragDidFinishScrollCallback?
    public var rowActionCallback: TableViewRowActionCallback?
    public var reloadCallback: TableViewWasReloadedCallback?
    public var editCallback: TableViewRowEditActionCallback?
    public var sections: [TableViewSection] { get { _frozenSections } set { set(sections: newValue) } }
    public var selectionSound: ControlInteractionSound? = UISoundDefault.tap
    public var isKeyboardSizeSensitive = true
    public let debounceDelay: TimeInterval

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public init(debounceDelay: TimeInterval = 0.3, sections: [TableViewSection]? = nil) {
        self.debounceDelay = debounceDelay
        super.init(frame: CGRect.zero, style: .plain)
        delegate = self
        dataSource = self
        estimatedRowHeight = 44.0
        rowHeight = UITableView.automaticDimension
        estimatedSectionHeaderHeight = 44.0
        estimatedSectionFooterHeight = 44.0
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
            isPrefetchingEnabled = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(_keyboardAppearanceWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_keyboardAppearanceWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        if let sections {
            set(sections: sections)
        }
    }

    public func set(sections: [TableViewSection], completion: (() -> Void)? = nil) {
        set(sections: sections, isReloading: false, completion: completion)
    }

    public func reload(with sections: [TableViewSection], completion: (() -> Void)? = nil) {
        set(sections: sections, isReloading: true, completion: completion)
    }

// MARK: private methods

    private let queue = {
        $0.maxConcurrentOperationCount = 1
        return $0
    }(AsyncOperationQueue(underlyingQueue: .main))
    private var _frozenSections: [TableViewSection] = []
    private lazy var _reloadDebouncer = {
        $0.reloadFinishCallback = { [weak self] in self?._reloaded() }
        return $0
    }(ReloadDebouncer(interval: debounceDelay, queue: queue))
    private var _endScrollingAnimationCallbacks: [TableViewEndScrollingAnimationCallback] = []
    private var registredIdentifiers: [String] = []

    private func set(sections: [TableViewSection], isReloading: Bool, completion: (() -> Void)? = nil) {
        for section in sections {
            for item in section.items {
                if !registredIdentifiers.contains(item.reuseIdentifier) {
                    self.register(item.cellType, forCellReuseIdentifier: item.reuseIdentifier)
                    registredIdentifiers.append(item.reuseIdentifier)
                }
            }
            if let headerItem = section.headerItem, !registredIdentifiers.contains(headerItem.reuseIdentifier) {
                register(headerItem.viewType, forHeaderFooterViewReuseIdentifier: headerItem.reuseIdentifier)
            }
            if let footerItem = section.footerItem, !registredIdentifiers.contains(footerItem.reuseIdentifier) {
                register(footerItem.viewType, forHeaderFooterViewReuseIdentifier: footerItem.reuseIdentifier)
            }
        }
        _reloadData(data: .init(sections: sections, isReloadRequested: isReloading), completion: completion)
    }

    @objc
    private func _reloadData(data: TableReloadData, completion: (() -> Void)? = nil) {
        _reloadDebouncer.add(operation: .init(block: { [weak self] finish in
            let blockFinish: () -> Void = {
                completion?()
                finish()
            }
            guard let self else { blockFinish(); return }
            self.queuedReload(isReloadRequested: data.isReloadRequested, sections: data.sections, completion: blockFinish)
        }))
    }

    private func queuedReload(isReloadRequested: Bool, sections: [TableViewSection], completion: @escaping () -> Void) {
        defer { completion() }
        UIView.performWithoutAnimation {
            let numberOfSections = numberOfSections
            if isReloadRequested ||
                self._frozenSections.isEmpty ||
                sections.isEmpty ||
                sections.count != numberOfSections ||
               Array(0..<numberOfSections).first(where: { sections[$0].items.count != numberOfRows(inSection: $0) ||
                   sections[$0].headerItem?.reuseIdentifier != _frozenSections[$0].headerItem?.reuseIdentifier ||
                   sections[$0].footerItem?.reuseIdentifier != _frozenSections[$0].footerItem?.reuseIdentifier}) != nil {
                self._frozenSections = sections
                super.reloadData()
            }else{
                self._frozenSections = sections
                guard !self._tryUpdateVisible() else { return }
                super.reloadData()
            }
        }
    }

    private func queuedDeleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        super.deleteRows(at: indexPaths, with: animation)
    }

    private func queuedMoveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        super.moveRow(at: indexPath, to: newIndexPath)
    }

    private func queuedInsertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        super.insertRows(at: indexPaths, with: animation)
    }

    private func queuedReloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        super.reloadRows(at: indexPaths, with: animation)
    }

    private func queuedDeleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        super.deleteSections(sections, with: animation)
    }

    private func queuedInsertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        super.insertSections(sections, with: animation)
    }

    private func _tryUpdateVisible() -> Bool {
        let isNeedReload: Bool
        let numberOfSections = self.numberOfSections
        if numberOfSections == _frozenSections.count,
           visibleCells.count <= _frozenSections.flatMap({$0.items}).count {
            isNeedReload = Array(0..<numberOfSections).first(where: { numberOfRows(inSection: $0) != _frozenSections[$0].items.count }) != nil
        }else{
            isNeedReload = true
        }
        guard !isNeedReload else { return false }
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
        Set((reconfigurePaths + reloadPaths).map({ $0.section })).forEach {
            (headerView(forSection: $0) as? TableSupplementaryView)?.item = _frozenSections[$0].headerItem
            (footerView(forSection: $0) as? TableSupplementaryView)?.item = _frozenSections[$0].footerItem
        }
        if !reconfigurePaths.isEmpty {
            _reconfigureRows(at: reconfigurePaths)
        }
        if !reloadPaths.isEmpty {
            reloadRows(at: reloadPaths, with: .none)
        }
        return true
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
        _frozenSections[indexPath.section].items[indexPath.row]
    }

    func _reloaded() {
        reloadCallback?()
    }

    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_checkInitiatedScrollDidStop), object: nil)
    }

// MARK: unsupported edit methods
    open override func reloadData() {}
    open override func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {}
    open override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {}
    open override func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {}
    open override func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {}
    open override func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {}
    open override func moveSection(_ section: Int, toSection newSection: Int) {}

// MARK: section header methods
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < _frozenSections.count else { return nil }
        let section = _frozenSections[section]
        guard let item = section.headerItem,
              let reusableView = tableView.dequeueReusableHeaderFooterView(withIdentifier: item.reuseIdentifier) as? TableSupplementaryView else {
            return nil
        }
        reusableView.item = item
        return reusableView
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section < _frozenSections.count else { return 0 }
        return _frozenSections[section].headerItem?.height ?? 0
    }

// MARK: section footer methods
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        guard section < _frozenSections.count else { return nil }
        let section = _frozenSections[section]
        guard let item = section.footerItem,
              let reusableView = tableView.dequeueReusableHeaderFooterView(withIdentifier: item.reuseIdentifier) as? TableSupplementaryView else {
            return nil
        }
        reusableView.item = item
        return reusableView
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section < _frozenSections.count else { return 0 }
        return _frozenSections[section].footerItem?.height ?? 0
    }

// MARK: cells methods
    public func numberOfSections(in tableView: UITableView) -> Int { _frozenSections.count }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { _frozenSections[section].items.count }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = _frozenItem(at: indexPath)
        guard let cell = self.dequeueReusableCell(withIdentifier: item.reuseIdentifier) as? TableViewCell else { fatalError("cell is not registred") }
        cell.item = item
        configCellCallback?(cell)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectItemCallback, let item = (tableView.cellForRow(at: indexPath) as? TableViewCell)?.item else { return }
        selectionSound?.play()
        selectItemCallback(item)
    }

// MARK: cells edit methods

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard indexPath.section < _frozenSections.count, indexPath.row < _frozenSections[indexPath.section].items.count else { return .none }
        return _frozenItem(at: indexPath).editingStyle
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section < _frozenSections.count, indexPath.row < _frozenSections[indexPath.section].items.count else { return false }
        return _frozenItem(at: indexPath).isEditable
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.section < _frozenSections.count, indexPath.row < _frozenSections[indexPath.section].items.count else { return }
        let item = _frozenItem(at: indexPath)
        deleteRows(indexPaths: [indexPath]) { [weak self] _ in self?.editCallback?(item, indexPath, editingStyle) }
    }

    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section < _frozenSections.count, indexPath.row < _frozenSections[indexPath.section].items.count else { return nil }
        let item = _frozenItem(at: indexPath)
        guard !item.leadingActions.isEmpty else { return nil }
        return .init(actions: item.leadingActions)
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section < _frozenSections.count, indexPath.row < _frozenSections[indexPath.section].items.count else { return nil }
        let item = _frozenItem(at: indexPath)
        guard !item.trailingingActions.isEmpty else { return nil }
        return .init(actions: item.trailingingActions)
    }

// MARK: scroll methods
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { startScrollCallback?() }
    open func scrollViewDidScroll(_ scrollView: UIScrollView) { scrollCallback?() }
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { dragFinishCallback?() }
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        dragFinishCallback?()
    }
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_checkInitiatedScrollDidStop), object: nil)
        _notifyScrollAnimationDidFinish()
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
            let window = self.window,
            let superview = self.superview
            else { return }

        let h: CGFloat = .maximum(superview.bounds.height - superview.convert(keyboardRect, from: window).origin.y, 0)
        self.setNeedsLayout()
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue(curve << 16)), animations: {
            self.layoutIfNeeded()
            self.contentInset.bottom = h
            if #available(iOS 13, *) {
                self.verticalScrollIndicatorInsets.bottom = h
            }else{
                self.scrollIndicatorInsets.bottom = h
            }
        }) { _ in }
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

extension UITableView {

    public func layoutTableHeaderView() {
        guard let headerView = self.tableHeaderView else { return }
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let headerWidth = headerView.bounds.size.width
        let temporaryWidthConstraint = headerView.widthAnchor.constraint(equalToConstant: headerWidth)
        headerView.addConstraint(temporaryWidthConstraint)
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = headerSize.height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        self.tableHeaderView = headerView
        headerView.removeConstraint(temporaryWidthConstraint)
        headerView.translatesAutoresizingMaskIntoConstraints = true
    }

    public func layoutTableFooterView() {
        guard let footerView = self.tableFooterView else { return }
        footerView.translatesAutoresizingMaskIntoConstraints = false
        let footerWidth = footerView.bounds.size.width
        let temporaryWidthConstraint = footerView.widthAnchor.constraint(equalToConstant: footerWidth)
        footerView.addConstraint(temporaryWidthConstraint)
        footerView.setNeedsLayout()
        footerView.layoutIfNeeded()
        let footerSize = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = footerSize.height
        var frame = footerView.frame
        frame.size.height = height
        footerView.frame = frame
        self.tableFooterView = footerView
        footerView.removeConstraint(temporaryWidthConstraint)
        footerView.translatesAutoresizingMaskIntoConstraints = true
    }
}

private class TableReloadData: NSObject {
    let sections: [TableViewSection]
    let isReloadRequested: Bool

    init(sections: [TableViewSection], isReloadRequested: Bool) {
        self.sections = sections
        self.isReloadRequested = isReloadRequested
    }
}

private class TableReloadOperation: AsyncOperation, @unchecked Sendable {}

private class ReloadDebouncer {
    private var workItem: DispatchWorkItem?
    private weak var queue: AsyncOperationQueue?
    private var lastTS: TimeInterval = 0
    private let interval: TimeInterval
    private let syncQueue: DispatchQueue = .main
    var reloadFinishCallback: (() -> Void)?

    init(interval: TimeInterval = 0.3, queue: AsyncOperationQueue) {
        self.interval = interval
        self.queue = queue
    }

    deinit {
        workItem?.cancel()
        workItem = nil
    }

    func add(operation: AsyncOperation) {
        let block = { [weak self] in
            self?.lastTS = INC_SystemUptime.uptime()
            self?.queue?.addOperation(operation)
            self?.queue?.add { self?.reloadFinishCallback?(); $0() }
        }
        let now = INC_SystemUptime.uptime()
        guard now - lastTS < interval else { block(); return }
        workItem?.cancel()
        workItem = DispatchWorkItem(block: block)
        syncQueue.asyncAfter(deadline: .now() + lastTS + interval - now, execute: workItem!)
    }
}

// MARK: row edit methods
extension TableView: TableViewEditInterface {
    public func deleteRows(indexPaths: [IndexPath], with animation: UITableView.RowAnimation = .automatic, completion: @escaping (Bool) -> Void) {
        queue.add { [weak self] finish in
            let block: (Bool) -> Void = { completion($0); finish() }
            guard let self else { block(false); return }
            var frizeSections = self._frozenSections
            var isOutBounds = false
            var map: [Int: [Int]] = [:]
            indexPaths.forEach { map[$0.section] = (map[$0.section] ?? []) + [$0.row] }
            for (sectionIndex, rows) in map {
                guard !isOutBounds, sectionIndex < frizeSections.count else {
                    isOutBounds = true
                    break
                }
                let section = frizeSections[sectionIndex]
                var items: [TableViewCellItem] = []
                for index in section.items.indices {
                    if !rows.contains(index) {
                        items.append(section.items[index])
                    }
                }
                frizeSections[sectionIndex] = section.copy(items: items)
            }

            guard !isOutBounds else { block(false); return }
            self._frozenSections = frizeSections
            self.performBatchUpdates({ self.queuedDeleteRows(at: indexPaths, with: animation) }, completion: block)
        }
    }

    public func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        queue.add { [weak self] finish in
            let block: (Bool) -> Void = { completion($0); finish() }
            guard let self else { block(false); return }
            var frizeSections = self._frozenSections
            guard indexPath.section < frizeSections.count, newIndexPath.section < frizeSections.count else {
                block(false)
                return
            }
            if indexPath.section != newIndexPath.section {
                var fromItems = frizeSections[indexPath.section].items
                var toItems = frizeSections[newIndexPath.section].items
                guard indexPath.row < fromItems.count, newIndexPath.row <= toItems.count else {
                    block(false)
                    return
                }
                toItems.insert(fromItems[indexPath.row], at: newIndexPath.row)
                fromItems.remove(at: indexPath.row)
                frizeSections[indexPath.section] = frizeSections[indexPath.section].copy(items: fromItems)
                frizeSections[newIndexPath.section] = frizeSections[newIndexPath.section].copy(items: toItems)
            }else{
                var items = frizeSections[indexPath.section].items
                guard indexPath.row < items.count, newIndexPath.row < items.count else {
                    block(false)
                    return
                }
                let item = items[indexPath.row]
                items.remove(at: indexPath.row)
                items.insert(item, at: newIndexPath.row-1)
                frizeSections[indexPath.section] = frizeSections[indexPath.section].copy(items: items)
            }
            self._frozenSections = frizeSections
            self.performBatchUpdates({ self.queuedMoveRow(at: indexPath, to: newIndexPath) }, completion: block)
        }
    }

    public func insert(items: [TableRawEditEntity], with animation: UITableView.RowAnimation = .automatic, completion: @escaping (Bool) -> Void) {
        queue.add { [weak self] finish in
            let block: (Bool) -> Void = { completion($0); finish() }
            guard let self else { block(false); return }
            var frizeSections = self._frozenSections
            var isOutBounds = false
            var map: [Int: [(Int,TableViewCellItem)]] = [:]
            items.forEach { map[$0.indexPath.section] = (map[$0.indexPath.section] ?? []) + [($0.indexPath.row, $0.item)] }
            for (sectionIndex, rowedItems) in map {
                guard !isOutBounds, sectionIndex < frizeSections.count else {
                    isOutBounds = true
                    break
                }
                let section = frizeSections[sectionIndex]
                var items: [TableViewCellItem] = []
                var rows: [Int] = rowedItems.map(\.0).sorted()
                guard rows.last ?? 0 < section.items.count + rows.count else {
                    isOutBounds = true
                    break
                }
                var oldIndex = 0
                let count = section.items.count + rows.count
                for index in 0..<count {
                    if rows.first == index, let item = rowedItems.first(where: { $0.0 == index })?.1 {
                        items.append(item)
                        rows.removeFirst()
                    }else if oldIndex < section.items.count{
                        items.append(section.items[oldIndex])
                        oldIndex += 1
                    }
                }
                frizeSections[sectionIndex] = section.copy(items: items)
            }
            guard !isOutBounds else { block(false); return }
            self._frozenSections = frizeSections
            self.performBatchUpdates({ self.queuedInsertRows(at: items.map(\.indexPath), with: animation) }, completion: block)
        }
    }

    public func reload(items: [TableRawEditEntity], with animation: UITableView.RowAnimation, completion: @escaping (Bool) -> Void) {
        queue.add { [weak self] finish in
            let block: (Bool) -> Void = { completion($0); finish() }
            guard let self else { block(false); return }
            var frizeSections = self._frozenSections
            var isOutBounds = false

            for item in items {
                guard item.indexPath.section < frizeSections.count,
                      item.indexPath.row < frizeSections[item.indexPath.section].items.count
                else {
                    isOutBounds = true
                    break
                }
                var items = frizeSections[item.indexPath.section].items
                items.replaceSubrange(item.indexPath.row...item.indexPath.row, with: [item.item])
                frizeSections[item.indexPath.section] = frizeSections[item.indexPath.section].copy(items: items)
            }
            guard !isOutBounds else { block(false); return }
            self._frozenSections = frizeSections
            self.performBatchUpdates({ self.queuedReloadRows(at: items.map(\.indexPath), with: animation) }, completion: block)
        }
    }

    public func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation = .automatic, completion: @escaping (Bool) -> Void) {
        queue.add { [weak self] finish in
            let block: (Bool) -> Void = { completion($0); finish() }
            guard let self, sections.max() ?? 0 < self._frozenSections.count else { block(false); return }
            var frizeSections: [TableViewSection] = []
            for index in self._frozenSections.indices {
                guard !sections.contains(index) else { continue }
                frizeSections.append(self._frozenSections[index])
            }
            self._frozenSections = frizeSections
            self.performBatchUpdates({ self.queuedDeleteSections(sections, with: animation) }, completion: block)
        }
    }

    public func insertSections(_ sections: [TableSectionEditEntity], with animation: UITableView.RowAnimation = .automatic, completion: @escaping (Bool) -> Void) {
        queue.add { [weak self] finish in
            let block: (Bool) -> Void = { completion($0); finish() }
            guard let self else { block(false); return }
            var rows: [Int] = sections.map(\.index).sorted()
            guard rows.last ?? 0 < self._frozenSections.count + rows.count else {
                block(false)
                return
            }
            var frizeSections: [TableViewSection] = []
            var oldIndex = 0
            let count = self._frozenSections.count + rows.count
            for index in 0..<count {
                if rows.first == index, let item = sections.first(where: { $0.index == index })?.section {
                    frizeSections.append(item)
                    rows.removeFirst()
                }else if oldIndex < self._frozenSections.count {
                    frizeSections.append(self._frozenSections[oldIndex])
                    oldIndex += 1
                }
            }
            self._frozenSections = frizeSections
            self.performBatchUpdates({ self.queuedInsertSections(.init(sections.map(\.index)), with: animation) }, completion: block)
        }
    }
}
