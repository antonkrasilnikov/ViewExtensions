//
//  ViewLocker.swift
//
//  Created by Антон Красильников on 25.04.2022.
//

import Foundation
import UIKit

private class LockedView {
    weak var view: UIView?
    var count: Int = 0 {
        didSet {
            view?.isUserInteractionEnabled = !(count > 0)
        }
    }
    
    init(view: UIView) {
        self.view = view
    }
}

open class ViewLocker {
    private static var pointers: [LockedView] = []
    
    public static func lock(view: UIView) {

        compact()
        
        let pointer: LockedView
        
        if let locked = pointers.first(where: { $0.view === view}) {
            pointer = locked
        }else{
            pointer = LockedView(view: view)
            pointers.append(pointer)
        }
        pointer.count += 1
    }
    
    public static func unlock(view: UIView) {
        
        compact()
        
        if let lockedIndex = pointers.firstIndex(where: { $0.view === view }) {
            pointers[lockedIndex].count -= 1
            if pointers[lockedIndex].count <= 0 {
                pointers.remove(at: lockedIndex)
            }
        }
    }
    
    private static func compact() {
        pointers.removeAll(where: { $0.view == nil })
    }
}
