//
//  StringExtensions.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/19/24.
//

import Foundation

extension String {
    func formatted(with args: CVarArg...) -> String {
        return String(format: self, args)
    }
}
