//
//  TransactionList.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import SwiftUI

struct TransactionList: View {
    let transactions: [Date: [Transaction]]
    let parentChestName: String
    let onDeleteTransaction: VoidHandler<Transaction>
    @Binding var editingTransaction: Transaction?
    @State private var showDeleteAlert: Bool = false
    @State private var deletedTransaction: Transaction?
    
    init(
        transactions: [Transaction],
        parentChestName: String,
        editingTransaction: Binding<Transaction?>,
        onDeleteTransaction: @escaping VoidHandler<Transaction>
    ) {
        self.transactions = Dictionary(grouping: transactions, by: \.transactionDate.millisecondToDate.startOfDay)
        self.parentChestName = parentChestName
        self._editingTransaction = editingTransaction
        self.onDeleteTransaction = onDeleteTransaction
    }
    
    var body: some View {
        List {
            ForEach(transactions.keys.sorted(), id: \.millisecondsSince1970) { date in
                Section(date.ddMMyyyyGMT) {
                    ForEach(transactions[date]!, id: \.identifier) { transaction in
                        TransactionRow(transaction: transaction)
                            .contextMenu {
                                Button(action: { editingTransaction = transaction }) {
                                    Label("Edit Labels", systemImage: "square.and.pencil")
                                }
                            }
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
        editingTransaction: .constant(nil),
        onDeleteTransaction: { _ in }
    )
}
