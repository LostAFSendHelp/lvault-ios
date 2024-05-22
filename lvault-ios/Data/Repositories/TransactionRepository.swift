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
    func getTransactions(chest: Chest) -> AnyPublisher<[Transaction], Error>
    func createTransaction(amount: Double, date: Double, chest: Chest) -> AnyPublisher<Transaction, Error>
    func deleteTransaction(_ transaction: Transaction) -> AnyPublisher<Void, Error>
}

class TransactionRepositoryImpl: TransactionRepository {
    private let persistence: PersistenceController
    
    init(persistence: PersistenceController) {
        self.persistence = persistence
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
    
    func createTransaction(amount: Double, date: Double, chest: Chest) -> AnyPublisher<Transaction, Error> {
        Future { [unowned self] promise in
            guard let chest = chest as? ChestCSO else {
                promise(.failure(LVaultError.invalidArguments("Expected ChestCSO")))
                return
            }
            
            persistence.create(
                { (cso: TransactionCSO, transaction: AsynchronousDataTransaction) -> Void in
                    let chest = transaction.edit(chest)!
                    cso.amount = amount
                    cso.transactionDate = date
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
