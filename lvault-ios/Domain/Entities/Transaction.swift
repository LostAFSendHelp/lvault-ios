//
//  Transaction.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/29/24.
//

protocol Transaction {
    var id: String { get }
    var amount: Double { get }
    var transactionDate: Double { get }
    var labels: [TransactionLabel] { get }
    var createdAt: Double { get }
}

extension Transaction {
    var amountText: String {
        return (amount > 0 ? "+" : "") + "%.2f".formatted(with: amount)
    }
    
    var dateText: String {
        return transactionDate.millisecondToDate.ddMMyyyyGMT
    }
    
    var timeText: String {
        return transactionDate.millisecondToDate.HHmmGMT
    }
}

struct TransactionDTO: Transaction {
    let id: String
    let amount: Double
    let transactionDate: Double
    let labels: [TransactionLabel]
    let createdAt: Double
}
