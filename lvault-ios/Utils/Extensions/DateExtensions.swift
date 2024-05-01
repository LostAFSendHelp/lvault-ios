//
//  DateExtensions.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/1/24.
//

import Foundation

extension Date {
    var millisecondsSince1970: Double {
        return timeIntervalSince1970 * 1000
    }
}
