//
//  StringExtensions.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 07/01/2024.
//

import Foundation

extension String {
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
