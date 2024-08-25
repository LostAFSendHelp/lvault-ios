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
    
    static let eeeddMMyyyyGMT: DateFormatter = .create(format: "eee, dd/MM/yyyy z")
    
    static let eeeddMMyyyy: DateFormatter = .create(format: "eee, dd/MM/yyyy")
    
    static let HHmm: DateFormatter = .create(format: "HH:mm")
    
    static let HHmmGMT: DateFormatter = .create(format: "HH:mm z")
    
    static let MMMMyyyyGMT: DateFormatter = .create(format: "MMMM, yyyy z")
}

extension Date {
    var millisecondsSince1970: Double {
        return timeIntervalSince1970 * 1000
    }
    
    var ddMMyyyyGMT: String {
        DateFormatter.ddMMyyyyGMT.string(from: self)
    }
    
    var eeeddMMyyyyGMT: String {
        DateFormatter.eeeddMMyyyyGMT.string(from: self)
    }
    
    var eeeddMMyyyy: String {
        DateFormatter.eeeddMMyyyy.string(from: self)
    }
    
    var HHmm: String {
        DateFormatter.HHmm.string(from: self)
    }
    
    var HHmmGMT: String {
        DateFormatter.HHmmGMT.string(from: self)
    }
    
    var MMMMyyyyGMT: String {
        DateFormatter.MMMMyyyyGMT.string(from: self)
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var startOfMonth: Date {
        return Calendar.current.dateInterval(of: .month, for: self)!.start
    }
    
    var endOfMonth: Date {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: self)!
        return nextMonth.startOfMonth
    }
}
