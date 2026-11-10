//
//  LayoutCircleChecker.swift
//  ViewExtensions
//
//  Created by Anton Krasilnikov on 10/11/2026.
//

import Foundation

@MainActor
public
class LayoutCircleChecker: NSObject {
    private var requestCount = 0
    private var isCircleWarning: Bool { requestCount > 5 }

    func apply(layout: @MainActor () -> Void) {
        guard !isCircleWarning else { return }
        requestCount += 1
        layout()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(finish), object: nil)
        perform(#selector(finish), with: nil, afterDelay: 0)
    }

    @objc
    private
    func finish() {
        requestCount = 0
    }
}
