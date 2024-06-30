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
    func deleteChest(_ chest: Chest) -> AnyPublisher<Void, Error>
    func transfer(from: Chest, to: Chest, amount: Double, at: Double, note: String?) -> AnyPublisher<Void, Error>
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
    
    func deleteChest(_ chest: Chest) -> AnyPublisher<Void, Error> {
        Future { [unowned self] promise in
            guard let chest = chest as? ChestCSO else {
                promise(.failure(LVaultError.invalidArguments("Expected ChestCSO")))
                return
            }
            
            persistence.delete(
                chest,
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
    
    func transfer(
        from: Chest,
        to: Chest,
        amount: Double,
        at: TimeInterval,
        note: String?
    ) -> AnyPublisher<Void, Error> {
        Future { [unowned self] promise in
            guard let from = from as? ChestCSO,
                  let to = to as? ChestCSO
            else {
                promise(.failure(LVaultError.invalidArguments("Expected ChestCSO")))
                return
            }
            
            guard from.id != to.id else {
                promise(.failure(LVaultError.invalidArguments("Cannot transfer to the same chest")))
                return
            }
            
            guard amount > 0 else {
                promise(.failure(LVaultError.invalidArguments("Invalid transfer amount")))
                return
            }
            
            persistence.perform(
                asynchronous: { transaction in
                    let from = transaction.edit(from)!
                    let to = transaction.edit(to)!
                    
                    let send = transaction.create(Into<TransactionCSO>())
                    send.rChest = from
                    send.transactionDate = at
                    send.amount = -amount
                    var fullSendNote = "To chest [\(to.name)]"
                    if let note { fullSendNote += " (\(note))" }
                    send.note = fullSendNote
                    send.isTransfer = true
                    from.currentAmount -= amount
                    
                    let receive = transaction.create(Into<TransactionCSO>())
                    receive.rChest = to
                    receive.transactionDate = at
                    receive.amount = amount
                    var fullReceiveNote = "From chest [\(from.name)]"
                    if let note { fullReceiveNote += " (\(note))" }
                    receive.note = fullReceiveNote
                    receive.isTransfer = true
                    to.currentAmount += amount
                },
                completion: { result in
                    switch result {
                    case .success:
                        promise(.success(()))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            )
        }.eraseToAnyPublisher()
    }
}
