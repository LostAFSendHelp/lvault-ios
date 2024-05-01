//
//  VaultEntity.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import Foundation

struct Vault {
    var id: String
    var name: String
    var chests: [Chest]
    var createdAt: Double
}

extension Vault {
    static func create(name: String) -> Vault {
        return .init(id: UUID().uuidString, name: name, chests: [], createdAt: 0)
    }
    
    func withChest(name: String, amount: Double = 1000) -> Vault {
        let chest = Chest.create(vaultId: id, name: name, initialAmount: amount, createdAt: 0)
        return .init(id: id, name: self.name, chests: chests + [chest], createdAt: 0)
    }
}
