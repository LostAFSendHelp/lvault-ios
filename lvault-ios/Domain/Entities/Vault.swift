//
//  Vault.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import Foundation

protocol Vault {
    var id: String { get }
    var name: String { get }
    var chests: [Chest] { get }
    var createdAt: Double { get }
}

struct VaultDTO: Vault {
    let id: String
    let name: String
    let chests: [Chest]
    let createdAt: Double
}

extension VaultDTO {
    static func create(name: String) -> VaultDTO {
        return .init(id: UUID().uuidString, name: name, chests: [], createdAt: 0)
    }
    
    func withChest(name: String, amount: Double = 1000) -> VaultDTO {
        let chest = ChestDTO.create(vaultId: id, name: name, initialAmount: amount, createdAt: 0)
        return .init(id: id, name: self.name, chests: chests + [chest], createdAt: 0)
    }
}
