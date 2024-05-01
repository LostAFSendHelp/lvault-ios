//
//  Vault+CSO.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/29/24.
//

extension Vault {
    static func fromCSO(_ cso: VaultCSO) -> Vault {
        return .init(
            id: cso.id,
            name: cso.name,
            chests: cso.chests.map({ Chest.fromCSO($0) }),
            createdAt: cso.createdAt
        )
    }
}
