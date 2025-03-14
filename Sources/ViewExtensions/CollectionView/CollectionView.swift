import Foundation
import UIKit
import Timers

public enum CollectionViewSupplementaryLayout {
    case fullWidthAspectHeight(aspect: CGFloat)
    case fullWidth(height: CGFloat)
    case sectionWidthAspectHeight(aspect: CGFloat)
    case sectionWidth(height: CGFloat)
}

open class CollectionSupplementaryItem {
    public let reuseIdentifier: String
    public let viewType: AnyClass
    public let layout: CollectionViewSupplementaryLayout

    public init(layout: CollectionViewSupplementaryLayout, reuseIdentifier: String, viewType: AnyClass) {
        self.layout = layout
        self.reuseIdentifier = reuseIdentifier
        self.viewType = viewType
    }
}

open class CollectionSupplementaryView: UICollectionReusableView {
    open var item: CollectionSupplementaryItem?
    open var sizeSet = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public init() {
        super.init(frame: CGRect.zero)
        setup()
    }

    open func setup() {}

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !sizeSet {
            sizeSet = true
            setupSizes()
        }
    }

    open func setupSizes() {}
}

open class CollectionViewCellItem {
    public let reuseIdentifier: String
    public let cellType: AnyClass

    public init(reuseIdentifier: String, cellType: AnyClass) {
        self.reuseIdentifier = reuseIdentifier
        self.cellType = cellType
    }
}

open class CollectionViewCell: UICollectionViewCell {
    open var item: CollectionViewCellItem?
    open var sizeSet = false
    open var shouldBeOpaqueInTouch = true
    open var shouldScaleInTouch = false

    private var isTouchScaled = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    public init() {
        super.init(frame: CGRect.zero)
        setup()
    }

    open func setup() {}

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !sizeSet {
            sizeSet = true
            setupSizes()
        }
    }

    open func setupSizes() {}

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !shouldBeOpaqueInTouch {
            self.alpha = 0.5
        }
        if shouldScaleInTouch, self.transform == .identity {
            isTouchScaled = true
            UIView.animate(withDuration: 0.1) {
                self.transform = .init(scaleX: 0.95, y: 0.95)
            }
        }
        super.touchesBegan(touches, with: event)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDidEnd()
        super.touchesEnded(touches, with: event)
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDidEnd()
        super.touchesCancelled(touches, with: event)
    }

    private func touchDidEnd() {
        self.alpha = 1
        if isTouchScaled {
            isTouchScaled = false
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
}

public enum CollectionViewSectionItemLayout {
    case undef
    case fullWidthAspectHeight(aspect: CGFloat)
    case fullWidth(height: CGFloat)
    case rawAspectHeight(count: Int, aspect: CGFloat)
    case raw(count: Int, height: CGFloat)
}

open class CollectionViewSection {
    public let items: [CollectionViewCellItem]
    public let headerItem: CollectionSupplementaryItem?
    public let footerItem: CollectionSupplementaryItem?
    public let number: Int
    public let itemLayout: CollectionViewSectionItemLayout
    public let sectionInset: UIEdgeInsets
    public let minimumInteritemSpacing: CGFloat
    public let minimumLineSpacing: CGFloat

    public init(number: Int,
                items: [CollectionViewCellItem],
                headerItem: CollectionSupplementaryItem? = nil,
                footerItem: CollectionSupplementaryItem? = nil,
                itemLayout: CollectionViewSectionItemLayout = .undef,
                sectionInset: UIEdgeInsets = .zero,
                minimumInteritemSpacing: CGFloat = 0,
                minimumLineSpacing: CGFloat = 0) {
        self.number = number
        self.items = items
        self.headerItem = headerItem
        self.footerItem = footerItem
        self.itemLayout = itemLayout
        self.sectionInset = sectionInset
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
    }
}

public typealias CollectionViewCallback = (_ item: Any) -> Void
public typealias CollectionViewCellConfigCallback = (_ cell: CollectionViewCell) -> Void
public typealias CollectionViewStartScrollCallback = () -> Void
public typealias CollectionViewStartDidScrollCallback = () -> Void
public typealias CollectionViewWasReloadedCallback = () -> Void
public typealias CollectionViewScrollDidStopCallback = () -> Void

open class CollectionView: UICollectionView {
    public var registredIdentifiers: [String] = []

    public var selectItemCallback: CollectionViewCallback?
    public var configCellCallback: CollectionViewCellConfigCallback?
    public var startScrollCallback: CollectionViewStartScrollCallback?
    public var scrollCallback: CollectionViewStartDidScrollCallback?
    public var reloadCallback: CollectionViewWasReloadedCallback?
    public var stopScrollCallback: CollectionViewScrollDidStopCallback?

    public var sections: [CollectionViewSection] = [] {
        didSet {

            for section in self.sections {
                for item in section.items {
                    if !registredIdentifiers.contains(item.reuseIdentifier) {
                        register(item.cellType, forCellWithReuseIdentifier: item.reuseIdentifier)
                        registredIdentifiers.append(item.reuseIdentifier)
                    }
                    if let headerItem = section.headerItem, !registredIdentifiers.contains(headerItem.reuseIdentifier) {
                        register(headerItem.viewType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerItem.reuseIdentifier)
                    }
                    if let footerItem = section.footerItem, !registredIdentifiers.contains(footerItem.reuseIdentifier) {
                        register(footerItem.viewType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerItem.reuseIdentifier)
                    }
                }
            }

            _throttledReloadData()
        }
    }

    public var selectionSound: ControlInteractionSound? = UISoundDefault.tap

    private var _frizeSections: [CollectionViewSection] = []
    private var _nextPossibleReloadTS: TimeInterval = 0
    private var _reloadDelay: TimeInterval = 0.3

    @objc
    private func _throttledReloadData() {
        let currentTS = INC_SystemUptime.uptime()
        if currentTS >= _nextPossibleReloadTS {
            _nextPossibleReloadTS = currentTS + _reloadDelay

            if _frizeSections.isEmpty ||
                sections.isEmpty ||
                sections.count != numberOfSections ||
                _frizeSections.count != sections.count ||
                Array(0..<numberOfSections).first(where: {
                    sections[$0].items.count != numberOfItems(inSection: $0) ||
                    sections[$0].headerItem?.reuseIdentifier != _frizeSections[$0].headerItem?.reuseIdentifier ||
                    sections[$0].footerItem?.reuseIdentifier != _frizeSections[$0].footerItem?.reuseIdentifier }) != nil {
                _frizeSections = sections
                reloadData()
            }else{
                _frizeSections = sections
                if !_tryUpdateVisible() {
                    reloadSections(IndexSet(0..<sections.count))
                }else{
                    perform(#selector(_reloaded), with: nil, afterDelay: 0)
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
            isNeedReload = Array(0..<numberOfSections).first(where: { numberOfItems(inSection: $0) != _frizeSections[$0].items.count }) != nil
        }else{
            isNeedReload = true
        }

        if !isNeedReload {
            var reloadPaths: [IndexPath] = []
            var reconfigurePaths: [IndexPath] = []

            let preparedCellPaths = subviews.filter({cell in return cell is CollectionViewCell && !visibleCells.contains(where: { $0 === cell })}).compactMap({ indexPath(for: $0 as! CollectionViewCell) })

            (indexPathsForVisibleItems + preparedCellPaths).forEach { indexPath in
                let item = _frozenItem(at: indexPath)
                if item.reuseIdentifier == cellForItem(at: indexPath)?.reuseIdentifier {
                    reconfigurePaths.append(indexPath)
                }else{
                    reloadPaths.append(indexPath)
                }
            }

            indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader).forEach { indexPath in
                (supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? CollectionSupplementaryView)?.item = _frozenHeaderItem(at: indexPath)
            }

            indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionFooter).forEach { indexPath in
                (supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: indexPath) as? CollectionSupplementaryView)?.item = _frozenFooterItem(at: indexPath)
            }

            if !reconfigurePaths.isEmpty {
                _reconfigureRows(at: reconfigurePaths)
            }

            if !reloadPaths.isEmpty {
                reloadItems(at: reloadPaths)
            }
        }
        return !isNeedReload
    }

    private func _reconfigureRows(at indexPaths: [IndexPath]) {
        if #available(iOS 15.0, *) {
            reconfigureItems(at: indexPaths)
        }else{
            indexPaths.forEach { indexPath in
                (cellForItem(at: indexPath) as? CollectionViewCell)?.item = _frozenItem(at: indexPath)
            }
        }
    }

    private func _frozenItem(at indexPath: IndexPath) -> CollectionViewCellItem {
        let section = _frizeSections[indexPath.section]
        return section.items[indexPath.row]
    }

    private func _frozenHeaderItem(at indexPath: IndexPath) -> CollectionSupplementaryItem? {
        _frizeSections[indexPath.section].headerItem
    }

    private func _frozenFooterItem(at indexPath: IndexPath) -> CollectionSupplementaryItem? {
        _frizeSections[indexPath.section].footerItem
    }

    public override func reloadData() {
        super.reloadData()
        perform(#selector(_reloaded), with: nil, afterDelay: 0)
    }

    public override func reloadSections(_ sections: IndexSet) {
        super.reloadSections(sections)
        perform(#selector(_reloaded), with: nil, afterDelay: 0)
    }

    @objc
    private func _reloaded() {
        reloadCallback?()
    }

    public init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        delegate = self
        dataSource = self
        isPrefetchingEnabled = false
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        dataSource = self
        isPrefetchingEnabled = false
    }

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        isPrefetchingEnabled = false
    }

    public init(sections: [CollectionViewSection], collectionViewLayout layout: UICollectionViewFlowLayout) {

        layout.estimatedItemSize = .init(width: 1, height: 1)

        super.init(frame: .zero, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        isPrefetchingEnabled = false
        self.sections = sections

    }

    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_throttledReloadData), object: nil)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_reloaded), object: nil)
    }
}

extension CollectionView: UICollectionViewDelegate,UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return _frizeSections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _frizeSections[section].items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let item = _frozenItem(at: indexPath)

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseIdentifier, for: indexPath) as? CollectionViewCell {
            cell.item = item
            if let configCellCallback = configCellCallback {
                configCellCallback(cell)
            }
            return cell
        }else{
            fatalError("cell is not registred")
        }

    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
            if let selectItemCallback = selectItemCallback {
                selectionSound?.play()
                selectItemCallback(cell)
            }
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startScrollCallback?()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?()
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            stopScrollCallback?()
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stopScrollCallback?()
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard indexPath.section < _frizeSections.count else { return UICollectionReusableView() }

        let reusableView: CollectionSupplementaryView?
        let section = _frizeSections[indexPath.section]
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let item = section.headerItem else { return UICollectionReusableView() }
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: item.reuseIdentifier, for: indexPath) as? CollectionSupplementaryView
            reusableView?.item = item
        case UICollectionView.elementKindSectionFooter:
            guard let item = section.footerItem else { return UICollectionReusableView() }
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: item.reuseIdentifier, for: indexPath) as? CollectionSupplementaryView
            reusableView?.item = item
        default:
            return UICollectionReusableView()
        }

        if let reusableView {
            return reusableView
        }else{
            fatalError("Supplementary view is not registred")
        }
    }

}

//extension CollectionView: UICollectionViewDelegateFlowLayout {
//    
//}
