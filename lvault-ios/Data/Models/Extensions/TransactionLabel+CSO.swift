//
//  TransactionLabel+CSO.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/29/24.
//

extension TransactionLabel {
    static func fromCSO(_ cso: TransactionLabelCSO) -> TransactionLabel {
        return .init(
            id: cso.id,
            name: cso.name,
            color: cso.color,
            createdAt: cso.createdAt
        )
    }
}

