import Foundation
import UIKit

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

open class CollectionViewSection {
    public let items: [CollectionViewCellItem]
    public let number: Int
    
    public init(number: Int, items: [CollectionViewCellItem]) {
        self.number = number
        self.items = items
    }
}

public typealias CollectionViewCallback = (_ item: Any) -> Void
public typealias CollectionViewCellConfigCallback = (_ cell: CollectionViewCell) -> Void
public typealias CollectionViewStartScrollCallback = () -> Void
public typealias CollectionViewStartDidScrollCallback = () -> Void
public typealias CollectionViewWasReloadedCallback = () -> Void

open class CollectionView: UICollectionView {
    public var registredCellIdentifiers: [String] = []
    
    public var selectItemCallback: CollectionViewCallback?
    public var configCellCallback: CollectionViewCellConfigCallback?
    public var startScrollCallback: CollectionViewStartScrollCallback?
    public var scrollCallback: CollectionViewStartDidScrollCallback?
    public var reloadCallback: CollectionViewWasReloadedCallback?
    
    public var sections: [CollectionViewSection] = [] {
        didSet {
            
            for section in self.sections {
                for item in section.items {
                    if !registredCellIdentifiers.contains(item.reuseIdentifier) {
                        register(item.cellType, forCellWithReuseIdentifier: item.reuseIdentifier)
                        registredCellIdentifiers.append(item.reuseIdentifier)
                    }
                }
            }
            
            let isNeedReload: Bool
                        
            if oldValue.count == sections.count,
               !oldValue.isEmpty,
               !visibleCells.isEmpty,
               visibleCells.count <= sections.flatMap({$0.items}).count {
                var isSame = true
                for i in 0..<oldValue.count {
                    isSame = oldValue[i].items.count == sections[i].items.count
                    if !isSame {
                        break
                    }
                }
                isNeedReload = !isSame
            }else{
                isNeedReload = true
            }
            
            if isNeedReload {
                _throttledReloadData()
            }else{
                visibleCells.forEach { cell in
                    if let itemCell = cell as? CollectionViewCell,
                       let indexPath = indexPath(for: cell),
                       indexPath.section < sections.count {
                        let items = sections[indexPath.section].items
                        if indexPath.row < items.count {
                            itemCell.item = items[indexPath.row]
                        }
                    }
                }
            }
            
        }
    }
    
    private var _nextPossibleReloadTS: TimeInterval = 0
    private var _reloadDelay: TimeInterval = 0.3
    
    @objc
    private func _throttledReloadData() {
        let currentTS = INCR_UISystemUptime.uptime()
        if currentTS >= _nextPossibleReloadTS {
            _nextPossibleReloadTS = currentTS + _reloadDelay

            if visibleCells.count == 0 || sections.count == 0 || sections.count != numberOfSections {
                reloadData()
            }else if !_tryUpdateVisible() {
                reloadSections(IndexSet(integer: sections.count-1))
            }
        }else{
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_throttledReloadData), object: nil)
            perform(#selector(_throttledReloadData), with: nil, afterDelay: _nextPossibleReloadTS - currentTS)
        }
    }
    
    private func _tryUpdateVisible() -> Bool {
        let isNeedReload: Bool
        
        let numberOfSections = self.numberOfSections
        
        if numberOfSections == sections.count,
           numberOfSections > 0,
           !visibleCells.isEmpty,
           visibleCells.count <= sections.flatMap({$0.items}).count {
            var isSame = true
            for i in 0..<numberOfSections {
                isSame = numberOfItems(inSection: i) == sections[i].items.count
                if !isSame {
                    break
                }
            }
            isNeedReload = !isSame
        }else{
            isNeedReload = true
        }
        
        if !isNeedReload {
            visibleCells.forEach { cell in
                if let itemCell = cell as? CollectionViewCell,
                   let indexPath = indexPath(for: cell),
                   indexPath.section < sections.count {
                    let items = sections[indexPath.section].items
                    if indexPath.row < items.count {
                        itemCell.item = items[indexPath.row]
                    }
                }
            }
        }
        return !isNeedReload
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
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        dataSource = self
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
    }
    
    public init(sections: [CollectionViewSection], collectionViewLayout layout: UICollectionViewFlowLayout) {
        
        layout.estimatedItemSize = .init(width: 1, height: 1)
        
        super.init(frame: .zero, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        self.sections = sections
        
    }
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_throttledReloadData), object: nil)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_reloaded), object: nil)
    }
}

extension CollectionView: UICollectionViewDelegate,UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
        
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
            selectItemCallback?(cell)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startScrollCallback?()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?()
    }
}

