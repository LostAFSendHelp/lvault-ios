//
//  ChestEntity.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import Foundation

struct Chest {
    var id: String
    var name: String
    var initialAmount: Double
    var transactions: [Transaction]
}

extension Chest {
    static func create(
        vaultId: String,
        name: String,
        initialAmount: Double = 1000
    ) -> Chest {
        return .init(
            id: UUID().uuidString,
            name: name,
            initialAmount: initialAmount,
            transactions: []
        )
    }
}
