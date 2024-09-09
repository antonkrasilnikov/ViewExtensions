//
//  Sound.swift
//  
//
//  Created by Антон Красильников on 03.04.2023.
//

import Foundation

public protocol ControlInteractionSound {
    static var none: Self { get }
    func play()
}

public struct UISoundDefault {
    public static var tap: ControlInteractionSound?
}
