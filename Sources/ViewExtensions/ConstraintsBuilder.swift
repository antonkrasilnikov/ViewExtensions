//
//  ConstraintsBuilder.swift
//  ViewExtensions
//
//  Created by Anton Krasilnikov on 11/11/2026.
//

import Foundation
import UIKit

@resultBuilder
public
struct ConstraintsBuilder {

    public static func buildBlock() -> [NSLayoutConstraint] {
        []
    }

    public
    static func buildBlock(_ components: NSLayoutConstraint...) -> [NSLayoutConstraint] {
        components
    }

    public
    static func buildBlock(_ components: [NSLayoutConstraint]...) -> [NSLayoutConstraint] {
        components.flatMap({ $0 })
    }

    public
    static func buildEither(first component: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        component
    }

    public
    static func buildEither(second component: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        component
    }

    public
    static func buildOptional(_ component: [NSLayoutConstraint]?) -> [NSLayoutConstraint] {
        component ?? []
    }
}
