//
//  TransactionLabelInteractor.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/25/24.
//

import Foundation
import SwiftUI

class TransactionLabelInteractor: ObservableObject {
    @Published private(set) var transactionLabels: LoadableList<TransactionLabel> = .loading
    
    private let repo: TransactionLabelRepository
    private var subscriptions: DisposeBag = []
    
    init(repo: TransactionLabelRepository) {
        self.repo = repo
    }
    
    func loadTransactionLabels() {
        transactionLabels = .loading
        repo.getTransactionLabels()
            .sink(
                receiveCompletion: { [weak self] result in
                    guard let self, case .failure(let error) = result else { return }
                    transactionLabels = .error(error)
                },
                receiveValue: { [weak self] data in
                    guard let self else { return }
                    transactionLabels = .data(data.sorted(by: { left, right in left.name < right.name }))
                }
            ).store(in: &subscriptions)
    }
    
    func createTransactionLabel(name: String, color: String, into binding: Binding<Loadable<TransactionLabel>>) {
        binding.wrappedValue = .loading
        repo.createTransactionLabel(name: name, color: color)
            .sink(
                receiveCompletion: { result in
                    guard case .failure(let error) = result else { return }
                    binding.wrappedValue = .error(error)
                },
                receiveValue: { transactionLabel in
                    binding.wrappedValue = .data(transactionLabel)
                }
            ).store(in: &subscriptions)
    }
    
    func updateTransactionLabel(
        _ transactionLabel: TransactionLabel,
        name: String,
        color: String,
        into binding: Binding<Loadable<TransactionLabel>>
    ) {
        binding.wrappedValue = .loading
        repo.updateTransactionLabel(transactionLabel, name: name, color: color)
            .sink(
                receiveCompletion: { result in
                    guard case .failure(let error) = result else { return }
                    binding.wrappedValue = .error(error)
                },
                receiveValue: { transactionLabel in
                    binding.wrappedValue = .data(transactionLabel)
                }
            ).store(in: &subscriptions)
    }
    
    func deleteTransactionLabel(
        _ transactionLabel: TransactionLabel,
        into binding: Binding<Loadable<Void>>? = nil,
        completion: EmptyVoidHandler? = nil
    ) {
        binding?.wrappedValue = .loading
        repo.deleteTransactionLabel(transactionLabel)
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
