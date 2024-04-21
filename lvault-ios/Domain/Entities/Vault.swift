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
}

extension Vault {
    static func create(name: String) -> Vault {
        return .init(id: UUID().uuidString, name: name, chests: [])
    }
    
    func withChest(name: String, amount: Double = 1000) -> Vault {
        let chest = Chest.create(vaultId: id, name: name, initialAmount: amount)
        return .init(id: id, name: self.name, chests: chests + [chest])
    }
}
