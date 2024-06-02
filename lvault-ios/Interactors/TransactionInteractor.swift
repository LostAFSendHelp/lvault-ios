//
//  TransactionInteractor.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import Foundation
import SwiftUI

class TransactionInteractor: ObservableObject {
    @Published var transactions: LoadableList<Transaction> = .loading
    
    private let chest: Chest
    private let repo: TransactionRepository
    private var subscriptions: DisposeBag = []
    
    var parentChestName: String { chest.name }
    var parentChestBalance: String { chest.currentAmountText }
    
    init(chest: Chest, repo: TransactionRepository) {
        self.chest = chest
        self.repo = repo
    }
    
    func loadTransactions() {
        transactions = .loading
        repo.getTransactions(chest: chest)
            .sink(
                receiveCompletion: { [weak self] result in
                    guard let self, case .failure(let error) = result else { return }
                    transactions = .error(error)
                },
                receiveValue: { [weak self] data in
                    guard let self else { return }
                    transactions = .data(data.sorted(by: { left, right in left.transactionDate < right.transactionDate }))
                }
            ).store(in: &subscriptions)
    }
    
    func createTransaction(
        amount: Double,
        date: Double,
        labels: [TransactionLabel],
        into binding: Binding<Loadable<Transaction>>
    ) {
        binding.wrappedValue = .loading
        repo.createTransaction(amount: amount, date: date, labels: labels, chest: chest)
            .sink(
                receiveCompletion: { result in
                    guard case .failure(let error) = result else { return }
                    binding.wrappedValue = .error(error)
                }, receiveValue: { transaction in
                    binding.wrappedValue = .data(transaction)
                }
            ).store(in: &subscriptions)
    }
    
    func updateTransaction(
        _ transaction: Transaction,
        setTransactionLabels labels: [TransactionLabel],
        into binding: Binding<Loadable<Void>>? = nil,
        completion: EmptyVoidHandler? = nil
    ) {
        binding?.wrappedValue = .loading
        repo.updateTransaction(transaction, setTransactionLabels: labels)
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .finished:
                        binding?.wrappedValue = .data(())
                    case .failure(let error):
                        binding?.wrappedValue = .error(error)
                    }
                    completion?()
                },
                receiveValue: { _ in }
            ).store(in: &subscriptions)
    }
    
    func deleteTransaction(
        _ transaction: Transaction,
        into binding: Binding<Loadable<Void>>? = nil,
        completion: EmptyVoidHandler? = nil
    ) {
        binding?.wrappedValue = .loading
        repo.deleteTransaction(transaction)
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .finished:
                        binding?.wrappedValue = .data(())
                    case .failure(let error):
                        binding?.wrappedValue = .error(error)
                    }
                    completion?()
                },
                receiveValue: { _ in }
            ).store(in: &subscriptions)
    }
}
