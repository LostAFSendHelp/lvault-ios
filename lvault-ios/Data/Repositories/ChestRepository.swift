//
//  ChestRepository.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/3/24.
//

import Foundation
import Combine
import CoreStore

protocol ChestRepository: AnyObject {
    func getChests(vault: Vault) -> AnyPublisher<[Chest], Error>
    func createChest(named name: String, initialAmount: Double, vault: Vault) -> AnyPublisher<Chest, Error>
}

class ChestRepositoryStub: ChestRepository {
    func getChests(vault: Vault) -> AnyPublisher<[Chest], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createChest(named name: String, initialAmount: Double, vault: Vault) -> AnyPublisher<Chest, Error> {
        return Just(ChestDTO.create(vaultId: "", name: "example chest"))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

class ChestRepositoryImpl: ChestRepository {
    private let persistence: PersistenceController
    
    init(persistence: PersistenceController) {
        self.persistence = persistence
    }
    
    func getChests(vault: Vault) -> AnyPublisher<[Chest], Error> {
        Future { promise in
            guard let vault = vault as? VaultCSO else {
                promise(.failure(LVaultError.invalidArguments("Expected VaultCSO")))
                return
            }
            promise(.success(vault.chests))
        }.eraseToAnyPublisher()
    }
    
    func createChest(named name: String, initialAmount: Double, vault: Vault) -> AnyPublisher<Chest, Error> {
        Future { [unowned self] promise in
            guard let vault = vault as? VaultCSO else {
                promise(.failure(LVaultError.invalidArguments("Expected VaultCSO")))
                return
            }
            
            persistence.create(
                { (cso: ChestCSO, transaction: AsynchronousDataTransaction) -> Void in
                    let vault = transaction.edit(vault)!
                    cso.name = name
                    cso.initialAmount = initialAmount
                    cso.currentAmount = initialAmount
                    cso.rVault = vault
                },
                completion: { result in
                    switch result {
                    case .success(let cso):
                        promise(.success(cso))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            )
        }
        .eraseToAnyPublisher()
    }
}
