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
    func getTransactions(chestId: String) -> AnyPublisher<[Transaction], Error>
    func createTransaction(amount: Double, date: Double, chestId: String) -> AnyPublisher<Transaction, Error>
}

class TransactionRepositoryStub: TransactionRepository {
    static let transactions: [Transaction] = [
        .init(id: "1", amount: 1000000, transactionDate: Date.now.millisecondsSince1970, labels: [], createdAt: Date.now.millisecondsSince1970),
        .init(id: "2", amount: -200000, transactionDate: Date.now.millisecondsSince1970, labels: [], createdAt: Date.now.millisecondsSince1970),
        .init(id: "3", amount: -150000, transactionDate: Date.now.millisecondsSince1970, labels: [], createdAt: Date.now.millisecondsSince1970),
    ]
    
    func getTransactions(chestId: String) -> AnyPublisher<[Transaction], Error> {
        return Just<[Transaction]>(Self.transactions).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func createTransaction(amount: Double, date: Double, chestId: String) -> AnyPublisher<Transaction, Error> {
        return Fail(error: LVaultError.custom("Fake error")).eraseToAnyPublisher()
    }
}

class TransactionRepositoryImpl: TransactionRepository {
    private let persistence: PersistenceController
    
    init(persistence: PersistenceController) {
        self.persistence = persistence
    }
    
    func getTransactions(chestId: String) -> AnyPublisher<[Transaction], Error> {
        Future { [unowned self] promise in
            do {
                let data: [TransactionCSO] = try persistence.fetchAll("chest.id == %@", chestId as NSString)
                let transactions = data.map({ Transaction.fromCSO($0) })
                promise(.success(transactions))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func createTransaction(amount: Double, date: Double, chestId: String) -> AnyPublisher<Transaction, Error> {
        Future { [unowned self] promise in
            var chest: ChestCSO?
            
            do {
                chest = try persistence.fetchFirst("id == %@", chestId as NSString)
            } catch {
                promise(.failure(error))
                return
            }
            
            guard let chest else {
                promise(.failure(LVaultError.notFound("chest with id \(chestId)")))
                return
            }
            
            persistence.create(
                { (cso: TransactionCSO, transaction: AsynchronousDataTransaction) -> Void in
                    let chest = transaction.edit(chest)!
                    cso.amount = amount
                    cso.transactionDate = date
                    cso.chest = chest
                    chest.currentAmount += amount
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
