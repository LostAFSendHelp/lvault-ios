//
//  TransactionList.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import SwiftUI

struct TransactionList: View {
    var transactions: [Transaction]
    var parentChestName: String
    @State private var showDeleteAlert: Bool = false
    @State private var deletedTransaction: Transaction?
    @EnvironmentObject private var transactionInteractor: TransactionInteractor
    
    var body: some View {
        List {
            ForEach(transactions, id: \.id) { transaction in
                TransactionRow(transaction: transaction)
            }.onDelete { indexSet in
                assert(indexSet.count == 1, "Only delete 1 item at a time")
                let transaction = transactions[indexSet.first!]
                deletedTransaction = transaction
                showDeleteAlert = true
            }
        }.alert(
            "Delete transaction?",
            isPresented: $showDeleteAlert,
            presenting: deletedTransaction
        ) { transaction in
            Button(role: .destructive) {
                deleteTransaction(transaction)
            } label: {
                Text("Delete")
            }
        } message: { transaction in
            Text("Delete transaction with value [\(transaction.amountText)] from chest [\(parentChestName)]? Current balance of the chest will be updated accordingly. This action cannot be reverted!")
        }
    }
}

private extension TransactionList {
    func deleteTransaction(_ transaction: Transaction) {
        transactionInteractor.deleteTransaction(
            transaction,
            completion: { transactionInteractor.loadTransactions() }
        )
    }
}

#Preview {
    TransactionList(
        transactions: TransactionRepositoryStub.transactions,
        parentChestName: "Example chest"
    )
}
