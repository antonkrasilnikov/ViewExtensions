//
//  VerticalFlowLayout.swift
//  ViewExtensions
//
//  Created by Антон Красильников on 05.02.2025.
//

import Foundation
import UIKit

open class VerticalFlowLayout: UICollectionViewLayout {

    private lazy var sectionsAttributes: [Int:[UICollectionViewLayoutAttributes]] = [:]

    private var allItemAttributes: [UICollectionViewLayoutAttributes] {
        var values: [UICollectionViewLayoutAttributes] = []
        for (_,attrs) in sectionsAttributes {
            values.append(contentsOf: attrs)
        }
        return values
    }

    private func attributes(section: Int) -> [UICollectionViewLayoutAttributes] {
        sectionsAttributes[section] ?? []
    }

    private func sectionItemAttributes(section: Int) -> [UICollectionViewLayoutAttributes] {
        sectionsAttributes[section]?.filter({ $0.representedElementCategory == .cell }) ?? []
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        allItemAttributes.filter { rect.intersects($0.frame) }
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let sectionsAttributes = sectionItemAttributes(section: indexPath.section)
        guard !sectionsAttributes.isEmpty, indexPath.item < sectionsAttributes.count else { return nil }
        return sectionsAttributes[indexPath.item]
    }

    public override var collectionViewContentSize: CGSize {
        guard let collectionView, collectionView.numberOfSections > 0 else { return .zero }
        return .init(width: collectionView.frame.width, height: allItemAttributes.reduce(CGRect.zero, { partialResult, attr in
            partialResult.union(attr.frame)
        }).height)
    }

    public func sectionSize(section: Int) -> CGSize {
        guard let collectionView, collectionView.numberOfSections > 0 else { return .zero }
        return .init(width: collectionView.frame.width, height: attributes(section: section).reduce(CGRect.zero, { partialResult, attr in
            partialResult.union(attr.frame)
        }).height)
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return newBounds.size != collectionView.bounds.size
    }

    public override func prepare() {
        super.prepare()
        layout()
    }

    private func layout() {
        guard let collectionView = collectionView as? CollectionView,
              !collectionView.sections.isEmpty else { return }

        var itemAttributes: [UICollectionViewLayoutAttributes] = []
        let width = collectionView.bounds.width

        var sectionIndex = 0
        var offsetY: CGFloat = 0

        collectionView.sections.forEach { section in
            let minimumInteritemSpacing: CGFloat = section.minimumInteritemSpacing
            let minimumLineSpacing: CGFloat = section.minimumLineSpacing
            let itemCount = section.items.count
            let sectionWidth = width - section.sectionInset.left - section.sectionInset.right
            var offsetX: CGFloat = section.sectionInset.left
            offsetY += section.sectionInset.top

            func addSupplementaryAttributes(item: CollectionSupplementaryItem, kind: String) {
                let x: CGFloat
                let supWidth: CGFloat
                let subHeight: CGFloat

                switch item.layout {
                case .fullWidthAspectHeight(let aspect):
                    x = 0
                    supWidth = width
                    subHeight = supWidth*aspect
                case .fullWidth(let height):
                    x = 0
                    supWidth = width
                    subHeight = height
                case .sectionWidthAspectHeight(let aspect):
                    x = offsetX
                    supWidth = sectionWidth
                    subHeight = supWidth*aspect
                case .sectionWidth(let height):
                    x = offsetX
                    supWidth = sectionWidth
                    subHeight = height
                }

                itemAttributes.append({
                    $0.frame = CGRect(x: x, y: offsetY, width: supWidth, height: subHeight)
                    return $0
                }(UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kind, with: [sectionIndex, 0])))
                offsetY += subHeight
            }

            // MARK: header
            if let headerItem = section.headerItem {
                addSupplementaryAttributes(item: headerItem, kind: UICollectionView.elementKindSectionHeader)
            }

            // MARK: items
            let itemSize: CGSize

            if itemCount > 0 {
                switch section.itemLayout {
                case .undef:
                    itemSize = .zero
                case .fullWidthAspectHeight(let aspect):
                    itemSize = .init(width: sectionWidth, height: sectionWidth*aspect)
                case .fullWidth(let height):
                    itemSize = .init(width: sectionWidth, height: height)
                case .rawAspectHeight(let count, let aspect):
                    if count > 0 {
                        let w = (sectionWidth - minimumInteritemSpacing*CGFloat(count-1))/CGFloat(count)
                        itemSize = .init(width: w, height: w*aspect)
                    }else{
                        itemSize = .zero
                    }
                case .raw(let count, let height):
                    if count > 0 {
                        itemSize = .init(width: (sectionWidth - minimumInteritemSpacing*CGFloat(count-1))/CGFloat(count), height: height)
                    }else{
                        itemSize = .zero
                    }
                }
            }else{
                itemSize = .zero
            }

            if itemSize != .zero {
                (0..<itemCount).forEach { index in
                    itemAttributes.append({
                        $0.frame = CGRect(x: offsetX, y: offsetY, width: itemSize.width, height: itemSize.height )
                        return $0
                    }(UICollectionViewLayoutAttributes(forCellWith: [sectionIndex, index])))

                    switch section.itemLayout {
                    case .undef:
                        break
                    case .fullWidthAspectHeight(_), .fullWidth(_):
                        offsetY += itemSize.height + minimumLineSpacing
                    case .rawAspectHeight(let count, _), .raw(let count, _):
                        if index != 0 && index % count == 0 {
                            offsetX = section.sectionInset.left
                            offsetY += itemSize.height + minimumLineSpacing
                        }else{
                            offsetX += itemSize.width + minimumInteritemSpacing
                            if index == itemCount - 1 {
                                offsetY += itemSize.height + minimumLineSpacing
                            }
                        }
                    }
                }
            }

            // MARK: footer
            if let footerItem = section.footerItem {
                addSupplementaryAttributes(item: footerItem, kind:  UICollectionView.elementKindSectionFooter)
            }

            sectionsAttributes[sectionIndex] = itemAttributes
            offsetY += section.sectionInset.bottom
            sectionIndex += 1
        }
    }
}
