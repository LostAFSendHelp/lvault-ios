//
//  ReportInteractor.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/12/24.
//

import Foundation
import SwiftUI

class ReportInteractor: ObservableObject {
    @Published private(set) var reportData: LoadableList<ReportSectionData> = .loading
    
    private let transactionRepo: TransactionRepository
    private var subscriptions: DisposeBag = []
    
    init(transactionRepo: TransactionRepository) {
        self.transactionRepo = transactionRepo
    }
    
    func generateReports() {
        reportData = .loading
        transactionRepo.getAllTransactions()
            .sink(
                receiveCompletion: { [weak self] result in
                    guard let self, case .failure(let error) = result else { return }
                    reportData = .error(error)
                },
                receiveValue: { [weak self] transactions in
                    guard let self else { return }
                    reportData = .data(generateReports(with: transactions))
                }
            ).store(in: &subscriptions)
    }
}

private extension ReportInteractor {
    func generateReports(with transactions: [Transaction]) -> [ReportSectionData] {
        let transactions = transactions.filter({ !$0.isTransfer })
        
        let transactionsByMonth = Dictionary(
            grouping: transactions,
            by: \.transactionDate.millisecondToDate.startOfMonth.millisecondsSince1970
        )
        
        return transactionsByMonth.map({ key, value in
            let spendings = value.filter({ $0.amount < 0 })
            let spendingGroup = createReportItemDataGroup(with: spendings)
            let earnings = value.filter({ $0.amount >= 0 })
            let earningGroup = createReportItemDataGroup(with: earnings)
            
            return ReportSectionData(
                startOfMonth: key,
                spendings: spendingGroup,
                earnings: earningGroup
            )
        })
    }
    
    private func createReportItemDataGroup(with transactions: [Transaction]) -> ReportItemDataGroup {
        var totalAmount: Double = 0
        var amountByLabel: [String: Double] = [:]
        
        let salt: String = "%%%\(UUID().uuidString)%%%"
        for transaction in transactions {
            totalAmount += transaction.amount
            
            if transaction.labels.isEmpty {
                let value = (amountByLabel["others_id" + salt + "Others"] ?? 0) + transaction.amount
                amountByLabel["others_id" + salt + "Others"] = value
            } else {
                for label in transaction.labels {
                    let key = label.id + salt + label.name
                    let value = (amountByLabel[key] ?? 0) + transaction.amount
                    amountByLabel[key] = value
                }
            }
        }
        
        var items = amountByLabel.map({ key, value in
            let components = key.split(separator: salt)
            assert(components.count == 2, "Key must be [id + salt + name]")
            let id = String(components[0])
            let name = String(components[1])
            return ReportItemData(labelId: id, label: name, amount: value)
        }).sorted(by: { $0.label < $1.label })
        
        if let index = items.firstIndex(where: \.labelId, equals: "others_id") {
            let others = items.remove(at: index)
            items.append(others)
        }
        
        return .init(items: items, totalAmount: totalAmount)
    }
}