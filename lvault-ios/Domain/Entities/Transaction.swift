//
//  Transaction.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/29/24.
//

import Foundation

protocol Transaction {
    var id: String { get }
    var amount: Double { get }
    var transactionDate: Double { get }
    var note: String? { get }
    var labels: [TransactionLabel] { get }
    var createdAt: Double { get }
}

extension Transaction {
    var identifier: String {
        return id + labels.map(\.identifier).joined() + (note ?? "")
    }
    
    var amountText: String {
        return (amount > 0 ? "+" : "") + amount.decimalText
    }
    
    var dateText: String {
        return transactionDate.millisecondToDate.ddMMyyyyGMT
    }
    
    var timeText: String {
        return transactionDate.millisecondToDate.HHmm
    }
}

struct TransactionDTO: Transaction {
    let id: String
    let amount: Double
    let transactionDate: Double
    let note: String?
    let labels: [TransactionLabel]
    let createdAt: Double
    
    func withLabels(_ count: Int) -> TransactionDTO {
        var labels: [TransactionLabelDTO] = []
        
        for index in 1...count {
            labels.append(.init(id: String(index), name: "Label \(index)", color: "#229933", createdAt: Date().millisecondsSince1970))
        }
        
        return .init(
            id: id,
            amount: amount,
            transactionDate: transactionDate,
            note: note,
            labels: labels,
            createdAt: createdAt
        )
    }
    
    func withNote(_ note: String?) -> TransactionDTO {
        return .init(
            id: id,
            amount: amount,
            transactionDate: transactionDate,
            note: note,
            labels: labels,
            createdAt: createdAt
        )
    }
    
    func withLabels(_ labels: [TransactionLabel]) -> TransactionDTO {
        return .init(
            id: id,
            amount: amount,
            transactionDate: transactionDate,
            note: note,
            labels: labels,
            createdAt: createdAt
        )
    }
}
