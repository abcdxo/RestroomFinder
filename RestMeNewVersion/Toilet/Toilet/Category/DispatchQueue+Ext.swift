//
//  DispatchQueue+Ext.swift
//  Toilet
//
//  Created by Cuc Nguyen on 3/17/20.
//  Copyright © 2020 Nick Nguyen. All rights reserved.
//
import Dispatch
import Foundation

extension DispatchQueue {
    /// Execute the provided closure after a `TimeInterval`.
    ///
    /// - Parameters:
    ///   - delay:   `TimeInterval` to delay execution.
    ///   - closure: Closure to execute.
    func after(_ delay: TimeInterval, execute closure: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: closure)
    }
}
