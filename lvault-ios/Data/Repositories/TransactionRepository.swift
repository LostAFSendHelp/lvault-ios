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
    func getTransactions(
        containingLabelId: String?,
        fromMillisecond: TimeInterval,
        toMillisecond: TimeInterval,
        excludeTransfers: Bool
    ) -> AnyPublisher<[Transaction], Error>
    func createTransaction(amount: Double, date: Double, note: String?, labels: [TransactionLabel], chest: Chest) -> AnyPublisher<Transaction, Error>
    func createTransactions(suggestions: [TransactionSuggestion], chest: Chest) -> AnyPublisher<Void, Error>
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
    
    func getTransactions(
        containingLabelId labelId: String?,
        fromMillisecond: TimeInterval,
        toMillisecond: TimeInterval,
        excludeTransfers: Bool
    ) -> AnyPublisher<[Transaction], Error> {
        return Future<[Transaction], Error> { [persistence] promise in
            do {
                let transactions: [TransactionCSO]
                
                if let labelId {
                    transactions = try persistence.fetchAll(
                        """
                        SUBQUERY(labels, $label, $label.id == %@).@count > 0
                        && transactionDate >= %d
                        && transactionDate < %d
                        \(excludeTransfers ? "&& isTransfer == FALSE" : "")
                        """,
                        labelId,
                        fromMillisecond,
                        toMillisecond
                    )
                } else {
                    transactions = try persistence.fetchAll(
                        """
                        labels.@count == 0
                        && transactionDate >= %d
                        && transactionDate < %d
                        \(excludeTransfers ? "&& isTransfer == FALSE" : "")
                        """,
                        fromMillisecond,
                        toMillisecond
                    )
                }
                
                promise(.success(transactions))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
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
                    _ = Self.createTransaction(
                        base: cso,
                        amount: amount,
                        note: note,
                        transactionDate: date,
                        labels: labels,
                        chest: chest,
                        asyncTrn: transaction
                    )
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
    
    func createTransactions(suggestions: [TransactionSuggestion], chest: any Chest) -> AnyPublisher<Void, Error> {
        Future { [unowned self] promise in
            guard let chest = chest as? ChestCSO else {promise(.failure(LVaultError.invalidArguments("Expected ChestCSO")))
                return
            }
            
            persistence.perform(
                asynchronous: { trn in
                    let chest = trn.edit(chest)!
                    suggestions.forEach { suggestion in
                        if let target = suggestion.transferTarget as? ChestCSO {
                            Self.createTransfer(
                                amount: suggestion.amount,
                                note: suggestion.note,
                                transactionDate: suggestion.timestamp,
                                from: chest,
                                to: target,
                                asyncTrn: trn
                            )
                        } else {
                            _ = Self.createTransaction(
                                amount: suggestion.amount,
                                note: suggestion.note,
                                transactionDate: suggestion.timestamp,
                                chest: chest,
                                asyncTrn: trn
                            )
                        }
                    }
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

private extension TransactionRepository {
    static func createTransaction(
        base: TransactionCSO? = nil,
        amount: Double,
        note: String?,
        transactionDate: Double,
        labels: [TransactionLabelCSO] = [],
        chest: ChestCSO,
        asyncTrn: AsynchronousDataTransaction
    ) -> TransactionCSO {
        let cso = base.map({ asyncTrn.edit($0)! }) ?? asyncTrn.create(Into<TransactionCSO>())
        let chest = asyncTrn.edit(chest)!
        let labels = labels.map({ asyncTrn.edit($0)! })
        
        cso.amount = amount
        cso.note = note
        cso.rLabels = Set(labels)
        cso.rChest = chest
        cso.transactionDate = transactionDate
        chest.currentAmount += amount
        
        return cso
    }
    
    static func createTransfer(
        amount: Double,
        note: String?,
        transactionDate: Double,
        from: ChestCSO,
        to: ChestCSO,
        asyncTrn: AsynchronousDataTransaction
    ) {
        let from = asyncTrn.edit(from)!
        let to = asyncTrn.edit(to)!
        
        let actualTo = amount < 0 ? to : from
        let actualFrom = amount < 0 ? from : to
        
        var fullSendNote = "To chest [\(actualTo.name)]"
        if let note { fullSendNote += " (\(note))" }
        
        var fullReceiveNote = "From chest [\(actualFrom.name)]"
        if let note { fullReceiveNote += " (\(note))" }
        
        let send = createTransaction(
            amount: amount,
            note: amount > 0 ? fullReceiveNote : fullSendNote,
            transactionDate: transactionDate,
            chest: from,
            asyncTrn: asyncTrn
        )
        send.isTransfer = true
        
        let receive = createTransaction(
            amount: amount * -1,
            note: (amount * -1) > 0 ? fullReceiveNote : fullSendNote,
            transactionDate: transactionDate,
            chest: to,
            asyncTrn: asyncTrn
        )
        receive.isTransfer = true
    }
}
