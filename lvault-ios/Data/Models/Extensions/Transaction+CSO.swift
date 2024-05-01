//
//  Transaction+CSO.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/29/24.
//

extension Transaction {
    static func fromCSO(_ cso: TransactionCSO) -> Transaction {
        return .init(
            id: cso.id,
            amount: cso.amount,
            labels: cso.labels.map({ TransactionLabel.fromCSO($0) }),
            createdAt: cso.createdAt
        )
    }
}
