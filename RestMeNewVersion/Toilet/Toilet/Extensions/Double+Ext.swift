//
//  Double+Ext.swift
//  Toilet
//
//  Created by Nick Nguyen on 10/16/20.
//  Copyright © 2020 Nick Nguyen. All rights reserved.
//

import Foundation

extension Double {
  func roundToDecimal(_ fractionDigits: Int) -> Double {
    let multiplier = pow(10, Double(fractionDigits))
    return Darwin.round(self * multiplier) / multiplier
  }
}
