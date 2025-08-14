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
    case authenticationFailure
    case apiError(ApiError?)
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
        case .authenticationFailure:
            return "Failed to authenticate user"
        case .apiError(let error):
            var message = "Network or API error"
            if let error {
                message += ": \(error.localizedDescription)"
            }
            return message
        }
    }
}
