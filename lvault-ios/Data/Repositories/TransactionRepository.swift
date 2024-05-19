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
}

class TransactionRepositoryStub: TransactionRepository {
    static let transactions: [TransactionDTO] = [
        .init(id: "1", amount: 1000000, transactionDate: Date.now.millisecondsSince1970, labels: [], createdAt: Date.now.millisecondsSince1970),
        .init(id: "2", amount: -200000, transactionDate: Date.now.millisecondsSince1970, labels: [], createdAt: Date.now.millisecondsSince1970),
        .init(id: "3", amount: -150000, transactionDate: Date.now.millisecondsSince1970, labels: [], createdAt: Date.now.millisecondsSince1970),
    ]
    
    func getTransactions(chest: Chest) -> AnyPublisher<[Transaction], Error> {
        return Just<[Transaction]>(Self.transactions).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func createTransaction(amount: Double, date: Double, chest: Chest) -> AnyPublisher<Transaction, Error> {
        return Fail(error: LVaultError.custom("Fake error")).eraseToAnyPublisher()
    }
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
}
