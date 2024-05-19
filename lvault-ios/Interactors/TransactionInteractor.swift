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
    
    func createTransaction(amount: Double, date: Double, into binding: Binding<Loadable<Transaction>>) {
        repo.createTransaction(amount: amount, date: date, chest: chest)
            .sink(
                receiveCompletion: { result in
                    guard case .failure(let error) = result else { return }
                    binding.wrappedValue = .error(error)
                }, receiveValue: { transaction in
                    binding.wrappedValue = .data(transaction)
                }
            ).store(in: &subscriptions)
    }
}
