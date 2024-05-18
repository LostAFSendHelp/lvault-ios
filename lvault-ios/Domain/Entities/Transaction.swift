//
//  Transaction.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/29/24.
//

struct Transaction {
    var id: String
    var amount: Double
    var transactionDate: Double
    var labels: [TransactionLabel]
    var createdAt: Double
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
