//
//  DateExtensions.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/1/24.
//

import Foundation

extension DateFormatter {
    private static func create(format: String) -> DateFormatter {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = format
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter
    }
    
    static let ddMMyyyyGMT: DateFormatter = .create(format: "dd/MM/yyyy z")
    
    static let HHmm: DateFormatter = .create(format: "HH:mm")
    
    static let HHmmGMT: DateFormatter = .create(format: "HH:mm z")
}

extension Date {
    var millisecondsSince1970: Double {
        return timeIntervalSince1970 * 1000
    }
    
    var ddMMyyyyGMT: String {
        DateFormatter.ddMMyyyyGMT.string(from: self)
    }
    
    var HHmm: String {
        DateFormatter.HHmm.string(from: self)
    }
    
    var HHmmGMT: String {
        DateFormatter.HHmmGMT.string(from: self)
    }
}
