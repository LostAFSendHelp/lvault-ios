//
//  VaultRepository.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import Foundation
import Combine

protocol VaultRepository: AnyObject {
    func getVaults() -> AnyPublisher<[Vault], Error>
    func createVault(named name: String) -> AnyPublisher<Vault, Error>
    func deleteVault(_ vault: Vault) -> AnyPublisher<Void, Error>
}

class VaultRepositoryStub: VaultRepository {
    static var data: [VaultDTO] {
        return [
            .create(name: "Vault 1").withChest(name: "Chest 1", amount: 1000),
            .create(name: "Vault 2").withChest(name: "Chest 2", amount: 2000),
            .create(name: "Vault 3").withChest(name: "Chest 3", amount: 3000),
            .create(name: "Vault 4").withChest(name: "Chest 4", amount: 4000),
            .create(name: "Vault 5").withChest(name: "Chest 5", amount: 5000),
        ]
    }
    
    func getVaults() -> AnyPublisher<[Vault], Error> {
        return Just(Self.data)
            .delay(for: 1, scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createVault(named name: String) -> AnyPublisher<Vault, Error> {
        return Just(VaultDTO.create(name: name)).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func deleteVault(_ vault: Vault) -> AnyPublisher<Void, Error> {
        return Just<Void>(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

class VaultRepositoryImpl: VaultRepository {
    private let persistence: PersistenceController
    
    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }
    
    func getVaults() -> AnyPublisher<[Vault], Error> {
        return Future { [unowned self] promise in
            do {
                let vaults: [VaultCSO] = try persistence.fetchAll()
                promise(.success(vaults))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func createVault(named name: String) -> AnyPublisher<Vault, Error> {
        return Future { [unowned self] promise in
            persistence.create(
                { (cso: VaultCSO, _) -> Void in
                    cso.name = name
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
        }.eraseToAnyPublisher()
    }
    
    func deleteVault(_ vault: Vault) -> AnyPublisher<Void, Error> {
        Future { [unowned self] promise in
            guard let vault = vault as? VaultCSO else {
                promise(.failure(LVaultError.invalidArguments("Expected VaultCSO")))
                return
            }
            
            persistence.delete(
                vault,
                completion: { result in
                    switch result {
                    case .success:
                        promise(.success(()))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            )
        }
        .eraseToAnyPublisher()
    }
}
