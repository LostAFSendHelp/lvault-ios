//
//  VaultRepositoryStub.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/22/24.
//

import Foundation
import Combine

class VaultRepositoryStub: VaultRepository {
    static let data: [VaultDTO] = [
        .create(name: "Vault 1").withChest(name: "Chest 1", amount: 1000),
        .create(name: "Vault 2").withChest(name: "Chest 2", amount: 2000),
        .create(name: "Vault 3").withChest(name: "Chest 3", amount: 3000),
        .create(name: "Vault 4").withChest(name: "Chest 4", amount: 4000),
        .create(name: "Vault 5").withChest(name: "Chest 5", amount: 5000),
    ]
    
    private(set) var data: [VaultDTO]
    
    init() {
        data = Self.data
    }
    
    func getVaults() -> AnyPublisher<[Vault], Error> {
        return Just(data)
            .delay(for: 0.5, scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createVault(named name: String) -> AnyPublisher<Vault, Error> {
        let new = VaultDTO.create(name: name)
        data.append(new)
        
        return Just(new)
            .delay(for: 0.5, scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteVault(_ vault: Vault) -> AnyPublisher<Void, Error> {
        guard let vault = vault as? VaultDTO else {
            return Fail(error: LVaultError.invalidArguments("Expected VaultDTO"))
                .eraseToAnyPublisher()
        }
        
        data.removeAll(where: { $0.id == vault.id })
        return Just<Void>(())
            .delay(for: 0.5, scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
