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
    func getChests(vaultId: String) -> AnyPublisher<[Chest], Error>
    func createChest(named name: String, initialAmount: Double, vaultId: String) -> AnyPublisher<Chest, Error>
}

class ChestRepositoryStub: ChestRepository {
    func getChests(vaultId: String) -> AnyPublisher<[Chest], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createChest(named name: String, initialAmount: Double, vaultId: String) -> AnyPublisher<Chest, Error> {
        return Just(Chest.create(vaultId: "", name: "example chest"))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

class ChestRepositoryImpl: ChestRepository {
    private let persistence: PersistenceController
    
    init(persistence: PersistenceController) {
        self.persistence = persistence
    }
    
    func getChests(vaultId: String) -> AnyPublisher<[Chest], Error> {
        Future { [unowned self] promise in
            do {
                let data: [ChestCSO] = try persistence.fetchAll("vault.id == %@", vaultId as NSString)
                let chests = data.map({ Chest.fromCSO($0) })
                promise(.success(chests))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func createChest(named name: String, initialAmount: Double, vaultId: String) -> AnyPublisher<Chest, Error> {
        Future { [unowned self] promise in
            var vault: VaultCSO?
            
            do {
                vault = try persistence.fetchFirst("id == %@", vaultId as NSString)
            } catch {
                promise(.failure(error))
                return
            }
            
            guard let vault else {
                promise(.failure(LVaultError.notFound("vault with id \(vaultId)")))
                return
            }
            
            persistence.create(
                { (cso: ChestCSO, transaction: AsynchronousDataTransaction) -> Void in
                    let vault = transaction.edit(vault)!
                    cso.name = name
                    cso.initialAmount = initialAmount
                    cso.currentAmount = initialAmount
                    cso.vault = vault
                },
                completion: { result in
                    switch result {
                    case .success(let cso):
                        promise(.success(.fromCSO(cso)))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            )
        }
        .eraseToAnyPublisher()
    }
}
