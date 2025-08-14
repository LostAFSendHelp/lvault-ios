//
//  TransactionInteractor.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import Foundation
import SwiftUI
import UIKit
import Combine

class TransactionInteractor: ObservableObject {
    @Published var transactions: LoadableList<Transaction> = .loading
    @Published var ocrSuggestions: Loadable<[TransactionSuggestion]> = .idle
    
    private let chest: Chest
    private let repo: TransactionRepository
    private let ocrService: OCRService
    private let scanService: ScanService
    private var subscriptions: DisposeBag = []
    
    var parentChestName: String { chest.name }
    var parentChestBalance: Double { chest.currentAmount }
    var parentChestBalanceText: String { chest.currentAmountText }
    
    init(chest: Chest, repo: TransactionRepository, ocrService: OCRService, scanService: ScanService = ScanServiceImpl()) {
        self.chest = chest
        self.repo = repo
        self.ocrService = ocrService
        self.scanService = scanService
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
        note: String?,
        labels: [TransactionLabel],
        into binding: Binding<Loadable<Transaction>>
    ) {
        binding.wrappedValue = .loading
        repo.createTransaction(amount: amount, date: date, note: note, labels: labels, chest: chest)
            .sink(
                receiveCompletion: { result in
                    guard case .failure(let error) = result else { return }
                    binding.wrappedValue = .error(error)
                }, receiveValue: { transaction in
                    binding.wrappedValue = .data(transaction)
                }
            ).store(in: &subscriptions)
    }
    
    func createTransactions(
        suggestions: [TransactionSuggestion],
        into binding: Binding<Loadable<Void>>? = nil,
        completion: EmptyVoidHandler? = nil
    ) {
        binding?.wrappedValue = .loading
        repo.createTransactions(suggestions: suggestions, chest: chest)
            .sink(
                receiveCompletion: { result in
                    defer { completion?() }
                    guard case .failure(let error) = result else { return }
                    binding?.wrappedValue = .error(error)
                },
                receiveValue: { _ in
                    binding?.wrappedValue = .data(())
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
    
    func updateTransaction(
        _ transaction: Transaction,
        setNote note: String?,
        into binding: Binding<Loadable<Void>>? = nil,
        completion: EmptyVoidHandler? = nil
    ) {
        binding?.wrappedValue = .loading
        repo.updateTransaction(transaction, setNote: note)
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
    
    func performOCR(on image: UIImage) -> AnyPublisher<OCRResponse, Error> {
        return ocrService.performOCR(on: image)
    }
    
    func suggestionFromOCR(ocrResponse: OCRResponse, labelDict: [String: String] = [:]) {
        ocrSuggestions = .loading
        
        let scanDocItems = ocrResponse.results.map { result in
            ScanDocDataItem(text: result.text, boundingBox: result.boundingBox.toBoundingBox())
        }
        
        let request = ScanDocRequest(
            items: scanDocItems,
            originalImageDimensions: ocrResponse.imageSize.toImageDimensions(),
            labelDict: labelDict
        )
        
        scanService.scanDoc(request: request)
            .sink(
                receiveCompletion: { [weak self] result in
                    guard let self, case .failure(let error) = result else { return }
                    ocrSuggestions = .error(error)
                },
                receiveValue: { [weak self] suggestions in
                    guard let self else { return }
                    ocrSuggestions = .data(suggestions)
                }
            ).store(in: &subscriptions)
    }
}
