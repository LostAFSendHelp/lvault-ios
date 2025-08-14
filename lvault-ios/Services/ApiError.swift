//
//  ApiError.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/14/25.
//

import Foundation

struct ErrorResponse: Codable, Error {
    let errors: [ApiError]
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return errors.map(\.localizedDescription).joined(separator: ";")
    }
}

struct ApiError: Codable, Error {
    let detail: String
    let code: String
}

extension ApiError: LocalizedError {
    var errorDescription: String? {
        "\(detail) (\(code))"
    }
}
