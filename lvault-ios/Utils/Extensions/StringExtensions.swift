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
