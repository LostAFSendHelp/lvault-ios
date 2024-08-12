//
//  TransactionRepository.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import Foundation
import Combine
import CoreStore

protocol TransactionRepository: AnyObject {
    func getAllTransactions() -> AnyPublisher<[Transaction], Error>
    func getTransactions(chest: Chest) -> AnyPublisher<[Transaction], Error>
    func createTransaction(amount: Double, date: Double, note: String?, labels: [TransactionLabel], chest: Chest) -> AnyPublisher<Transaction, Error>
    func deleteTransaction(_ transaction: Transaction) -> AnyPublisher<Void, Error>
    func updateTransaction(_ transaction: Transaction, setTransactionLabels labels: [TransactionLabel]) -> AnyPublisher<Transaction, Error>
    func updateTransaction(_ transaction: Transaction, setNote note: String?) -> AnyPublisher<Transaction, Error>
}

class TransactionRepositoryImpl: TransactionRepository {
    private let persistence: PersistenceController
    
    init(persistence: PersistenceController) {
        self.persistence = persistence
    }
    
    func getAllTransactions() -> AnyPublisher<[Transaction], Error> {
        Future { [persistence] promise in
            do {
                let allTransactions: [TransactionCSO] = try persistence.fetchAll()
                promise(.success(allTransactions))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func getTransactions(chest: Chest) -> AnyPublisher<[Transaction], Error> {
        Future { promise in
            guard let chest = chest as? ChestCSO else {
                promise(.failure(LVaultError.invalidArguments("Expected ChestCSO")))
                return
            }
            promise(.success(chest.rTransactions))
        }.eraseToAnyPublisher()
    }
    
    func createTransaction(
        amount: Double,
        date: Double,
        note: String?,
        labels: [TransactionLabel],
        chest: Chest
    ) -> AnyPublisher<Transaction, Error> {
        Future { [unowned self] promise in
            guard let chest = chest as? ChestCSO, let labels = labels as? [TransactionLabelCSO] else {
                promise(.failure(LVaultError.invalidArguments("Expected ChestCSO and TransactionLabelCSOs")))
                return
            }
            
            persistence.create(
                { (cso: TransactionCSO, transaction: AsynchronousDataTransaction) -> Void in
                    let chest = transaction.edit(chest)!
                    let labels = labels.map({ transaction.edit($0)! })
                    cso.amount = amount
                    cso.transactionDate = date
                    cso.note = note
                    cso.rLabels = Set(labels)
                    cso.rChest = chest
                    chest.currentAmount += amount
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
    
    func updateTransaction(_ transaction: Transaction, setTransactionLabels labels: [TransactionLabel]) -> AnyPublisher<Transaction, Error> {
        Future { [unowned self] promise in
            guard
                let transaction = transaction as? TransactionCSO,
                let labels = labels as? [TransactionLabelCSO]
            else {
                promise(.failure(LVaultError.invalidArguments("Expected TransactionCSO and TransactionLabelCSOs")))
                return
            }
            
            persistence.update(
                object: transaction,
                updates: { transaction, persistenceTrn in
                    let labels = labels.map({ persistenceTrn.edit($0)! })
                    transaction.rLabels = Set(labels)
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
    
    func updateTransaction(_ transaction: Transaction, setNote note: String?) -> AnyPublisher<Transaction, Error> {
        Future { [unowned self] promise in
            guard let transaction = transaction as? TransactionCSO else {
                promise(.failure(LVaultError.invalidArguments("Expected TransactionCSO and TransactionLabelCSOs")))
                return
            }
            
            persistence.update(
                object: transaction,
                updates: { transaction, persistenceTrn in
                    transaction.note = note
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
    
    func deleteTransaction(_ transaction: Transaction) -> AnyPublisher<Void, Error> {
        Future { [unowned self] promise in
            guard let transaction = transaction as? TransactionCSO else {
                promise(.failure(LVaultError.invalidArguments("Expected TransactionCSO")))
                return
            }
            
            persistence.delete(
                transaction,
                willDelete: { transaction, persistenceTrn in
                    let chest = transaction.rChest
                    chest?.currentAmount -= transaction.amount
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
        }
        .eraseToAnyPublisher()
    }
}
