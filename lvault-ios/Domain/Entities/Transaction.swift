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
    var isTransfer: Bool { get }
    var transactionDate: Double { get }
    var note: String? { get }
    var labels: [TransactionLabel] { get }
    var createdAt: Double { get }
    var chestName: String { get }
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
    
    var searchAttributes: [String] {
        return labels.map { $0.name } + [note.orEmpty]
    }
}

struct TransactionDTO: Transaction {
    let id: String
    let amount: Double
    let isTransfer: Bool
    let transactionDate: Double
    let note: String?
    let labels: [TransactionLabel]
    let createdAt: Double
    let chestName: String = "DTO chest"
    
    func withLabels(_ count: Int) -> TransactionDTO {
        var labels: [TransactionLabelDTO] = []
        
        for index in 1...count {
            labels.append(.init(id: String(index), name: "Label \(index)", color: "#229933", createdAt: Date().millisecondsSince1970))
        }
        
        return .init(
            id: id,
            amount: amount,
            isTransfer: isTransfer,
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
            isTransfer: isTransfer,
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
            isTransfer: isTransfer,
            transactionDate: transactionDate,
            note: note,
            labels: labels,
            createdAt: createdAt
        )
    }
}
