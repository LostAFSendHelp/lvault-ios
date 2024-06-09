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
    @Binding var ascendingByDate: Bool
    @Binding var editingTransaction: Transaction?
    @Binding var editingTransactionNote: Transaction?
    @State private var showDeleteAlert: Bool = false
    @State private var deletedTransaction: Transaction?
    
    private var sortedTransactionDates: [Date] {
        return transactions.keys.sorted(by: { left, right in ascendingByDate ? left < right : left > right })
    }
    
    private func sortedTransactionsFor(date: Date) -> [Transaction] {
        return transactions[date]!.sorted(by: { left, right in
            if ascendingByDate {
                return left.transactionDate < right.transactionDate
            } else {
                return left.transactionDate > right.transactionDate
            }
        })
    }
    
    init(
        transactions: [Transaction],
        parentChestName: String,
        ascendingByDate: Binding<Bool> = .constant(false),
        editingTransaction: Binding<Transaction?>,
        editingTransactionNote: Binding<Transaction?>,
        onDeleteTransaction: @escaping VoidHandler<Transaction>
    ) {
        self.transactions = Dictionary(grouping: transactions, by: \.transactionDate.millisecondToDate.startOfDay)
        self.parentChestName = parentChestName
        self._ascendingByDate = ascendingByDate
        self._editingTransaction = editingTransaction
        self._editingTransactionNote = editingTransactionNote
        self.onDeleteTransaction = onDeleteTransaction
    }
    
    var body: some View {
        List {
            ForEach(
                sortedTransactionDates,
                id: \.millisecondsSince1970
            ) { date in
                Section(date.eeeddMMyyyyGMT) {
                    ForEach(
                        sortedTransactionsFor(date: date),
                        id: \.identifier
                    ) { transaction in
                        TransactionRow(transaction: transaction)
                            .contextMenu {
                                Button(action: { editingTransaction = transaction }) {
                                    Label("Edit Labels", systemImage: "square.and.pencil")
                                }
                                Button(action: { editingTransactionNote = transaction }) {
                                    Label("Edit Note", systemImage: "pencil.and.list.clipboard")
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
        editingTransactionNote: .constant(nil),
        onDeleteTransaction: { _ in }
    )
}
