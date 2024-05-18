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
}
