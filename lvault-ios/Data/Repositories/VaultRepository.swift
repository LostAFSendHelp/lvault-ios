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
}

class VaultRepositoryStub: VaultRepository {
    static var data: [Vault] {
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
}

class VaultRepositoryImpl: VaultRepository {
    private let persistence: PersistenceController
    
    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }
    
    func getVaults() -> AnyPublisher<[Vault], Error> {
        return Future { [unowned self] promise in
            do {
                let data: [VaultCSO] = try persistence.fetchAll()
                let vaults = data.map({ Vault.fromCSO($0) })
                promise(.success(vaults))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func createVault(_ vault: Vault) -> AnyPublisher<Vault, Error> {
        return Future { [unowned self] promise in
            persistence.create(
                { (cso: VaultCSO) -> Void in
                    cso.name = vault.name
                },
                completion: { result in
                    switch result {
                    case .success:
                        promise(.success(vault))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            )
        }.eraseToAnyPublisher()
    }
}
