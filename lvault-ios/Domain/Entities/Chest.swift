//
//  Chest.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import Foundation

protocol Chest {
    var id: String { get }
    var name: String { get }
    var initialAmount: Double { get }
    var currentAmount: Double { get }
    var transactions: [Transaction] { get }
    var createdAt: Double { get }
}

extension Chest {
    var currentAmountText: String {
        return currentAmount.decimalText
    }
}

struct ChestDTO: Chest {
    let id: String
    let name: String
    let initialAmount: Double
    let currentAmount: Double
    let transactions: [Transaction]
    let createdAt: Double
}

extension ChestDTO {
    static func create(
        vaultId: String,
        name: String,
        initialAmount: Double = 1000,
        currentAmount: Double = 1000,
        createdAt: Double = 0
    ) -> ChestDTO {
        return .init(
            id: UUID().uuidString,
            name: name,
            initialAmount: initialAmount,
            currentAmount: currentAmount,
            transactions: [],
            createdAt: createdAt
        )
    }
}
