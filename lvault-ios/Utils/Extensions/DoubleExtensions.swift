//
//  DoubleExtensions.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/19/24.
//

import Foundation

extension Double {
    var millisecondToDate: Date {
        return Date.init(timeIntervalSince1970: self / 1000)
    }
    
    var decimalText: String {
        return NumberFormatter.decimal.string(from: self as NSNumber) ?? "%.2f".formatted(with: self)
    }
    
    var signedDecimalText: String {
        return (self > 0 ? "+" : "") + decimalText
    }
}
