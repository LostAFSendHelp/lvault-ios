//
//  NumberFormatterExtensions.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/22/24.
//

import Foundation

extension NumberFormatter {
    static let decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
