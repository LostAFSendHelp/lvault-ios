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
