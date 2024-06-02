//
//  TransactionRepositoryStub.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/22/24.
//

import Foundation
import Combine

class TransactionRepositoryStub: TransactionRepository {
    static let data: [TransactionDTO] = [
        .init(id: "1", amount: 1000000, transactionDate: Date.now.millisecondsSince1970, labels: [], createdAt: Date.now.millisecondsSince1970),
        .init(id: "2", amount: -200000.155, transactionDate: Date.now.millisecondsSince1970, labels: [], createdAt: Date.now.millisecondsSince1970),
        .init(id: "3", amount: -150000.89, transactionDate: Date.now.addingTimeInterval(24 * 60 * 60).millisecondsSince1970, labels: [], createdAt: Date.now.millisecondsSince1970),
    ]
    
    private var data: [TransactionDTO]
    
    init() {
        data = Self.data
    }
    
    func getTransactions(chest: Chest) -> AnyPublisher<[Transaction], Error> {
        return Just<[Transaction]>(data)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createTransaction(
        amount: Double,
        date: Double,
        labels: [TransactionLabel],
        chest: Chest
    ) -> AnyPublisher<Transaction, Error> {
        guard let labels = labels as? [TransactionLabelDTO] else {
            return Fail(error: LVaultError.invalidArguments("Expected TransactionLabelDTOs"))
                .eraseToAnyPublisher()
        }
        
        let new = TransactionDTO(id: UUID().uuidString, amount: amount, transactionDate: date, labels: labels, createdAt: date)
        data.append(new)
        
        return Just(new)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateTransaction(_ transaction: Transaction, setTransactionLabels labels: [TransactionLabel]) -> AnyPublisher<Transaction, Error> {
        guard let transaction = transaction as? TransactionDTO else {
            return Fail(error: LVaultError.invalidArguments("Expected TransactionDTO"))
                .eraseToAnyPublisher()
        }
        
        guard let index = data.firstIndex(where: { $0.id == transaction.id }) else {
            return Fail(error: LVaultError.notFound("TransactionDTO with id \(transaction.id)"))
                .eraseToAnyPublisher()
        }
        
        var target = data[index]
        target = target.withLabels(labels)
        data[index] = target
        
        return Just(target)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteTransaction(_ transaction: Transaction) -> AnyPublisher<Void, Error> {
        guard let transaction = transaction as? TransactionDTO else {
            return Fail(error: LVaultError.invalidArguments("Expected TransactionDTO"))
                .eraseToAnyPublisher()
        }
        
        data.removeAll(where: { $0.id == transaction.id })
        return Just<Void>(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
