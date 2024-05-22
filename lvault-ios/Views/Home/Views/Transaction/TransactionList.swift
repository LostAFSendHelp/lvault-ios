//
//  TransactionList.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import SwiftUI

struct TransactionList: View {
    var transactions: [Date: [Transaction]]
    var parentChestName: String
    var onDeleteTransaction: VoidHandler<Transaction>
    @State private var showDeleteAlert: Bool = false
    @State private var deletedTransaction: Transaction?
    
    init(transactions: [Transaction], parentChestName: String, onDeleteTransaction: @escaping VoidHandler<Transaction>) {
        self.transactions = Dictionary(grouping: transactions, by: \.transactionDate.millisecondToDate.startOfDay)
        self.parentChestName = parentChestName
        self.onDeleteTransaction = onDeleteTransaction
    }
    
    var body: some View {
        List {
            ForEach(transactions.keys.sorted(), id: \.millisecondsSince1970) { date in
                Section(date.ddMMyyyyGMT) {
                    ForEach(transactions[date]!, id: \.id) { transaction in
                        TransactionRow(transaction: transaction)
                    }.onDelete { indexSet in
                        assert(indexSet.count == 1, "Only delete 1 item at a time")
                        let transaction = transactions[date]![indexSet.first!]
                        deletedTransaction = transaction
                        showDeleteAlert = true
                    }
                }
            }
        }.alert(
            "Delete transaction?",
            isPresented: $showDeleteAlert,
            presenting: deletedTransaction
        ) { transaction in
            Button(role: .destructive) {
                onDeleteTransaction(transaction)
            } label: {
                Text("Delete")
            }
        } message: { transaction in
            Text("Delete transaction with value [\(transaction.amountText)] from chest [\(parentChestName)]? Current balance of the chest will be updated accordingly. This action cannot be reverted!")
        }
    }
}

#Preview {
    TransactionList(
        transactions: TransactionRepositoryStub.data,
        parentChestName: "Example chest",
        onDeleteTransaction: { _ in }
    )
}
