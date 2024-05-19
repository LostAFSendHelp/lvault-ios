//
//  LVaultError.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/30/24.
//

import Foundation

enum LVaultError: Error {
    case custom(String)
    case notFound(String?)
    case invalidArguments(String?)
}

extension LVaultError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .custom(let message):
            return message
        case .notFound(let clause):
            var message = "Data not found"
            if let clause {
                message += ": \(clause)"
            }
            return message
        case .invalidArguments(let clause):
            var message = "Invalid arguments"
            if let clause {
                message += ": \(clause)"
            }
            return message
        }
    }
}
