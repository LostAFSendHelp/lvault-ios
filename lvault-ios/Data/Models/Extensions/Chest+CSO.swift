//
//  Chest+CSO.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/29/24.
//

extension Chest {
    static func fromCSO(_ cso: ChestCSO) -> Chest {
        return .init(
            id: cso.id,
            name: cso.name,
            initialAmount: cso.initialAmount,
            currentAmount: cso.currentAmount,
            transactions: cso.transactions.map({ Transaction.fromCSO($0) }),
            createdAt: cso.createdAt
        )
    }
}
