//
//  StringExtensions.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/19/24.
//

import Foundation
import SwiftUI

extension String {
    func formatted(with args: CVarArg...) -> String {
        return String(format: self, args)
    }
}

extension String {
    var color: Color {
        return Color(hex: self)
    }
}

extension String {
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var strippingDiacritics: String {
        return folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: "đ", with: "d")
            .replacingOccurrences(of: "Đ", with: "D")
    }
}

extension Optional where Wrapped == String {
    var orEmpty: String {
        return self ?? ""
    }
}
