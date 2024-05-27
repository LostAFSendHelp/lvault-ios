//
//  ChestDetail.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import SwiftUI

struct ChestDetail: View {
    @State private var showCreateTransactionSheet = false
    @State private var editingTransaction: Transaction?
    @EnvironmentObject private var transactionInteractor: TransactionInteractor
    @EnvironmentObject private var di: DI
    
    private var showEditSheet: Binding<Bool> {
        .init(
            get: { editingTransaction != nil },
            set: { _ in editingTransaction = nil }
        )
    }
    
    var body: some View {
        buildStateView(transactionInteractor.transactions)
            .onAppear {
                transactionInteractor.loadTransactions()
            }
            .navigationTitle(Text(transactionInteractor.parentChestName))
            .toolbar {
                Button {
                    showCreateTransactionSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }.sheet(isPresented: $showCreateTransactionSheet) {
                CreateTransactionSheet(isPresented: $showCreateTransactionSheet)
            }.sheet(isPresented: showEditSheet) {
                EditTransactionSheet(isPresented: showEditSheet, transaction: editingTransaction!)
                    .environmentObject(di.container.getTransactionLabelInteractor())
            }
    }
}

private extension ChestDetail {
    @ViewBuilder
    func buildStateView(_ state: LoadableList<Transaction>) -> some View {
        switch state {
        case .data(let transactions):
            TransactionList(
                transactions: transactions,
                parentChestName: transactionInteractor.parentChestName,
                editingTransaction: $editingTransaction,
                onDeleteTransaction: deleteTransaction(_:)
            )
        case .error(let error):
            Text(error.localizedDescription)
        case .loading:
            ProgressView()
        default:
            EmptyView()
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactionInteractor.deleteTransaction(
            transaction,
            completion: { transactionInteractor.loadTransactions() }
        )
    }
}

#Preview {
    let interactor: TransactionInteractor = .init(
        chest: ChestDTO.create(vaultId: "1", name: "Example chest"),
        repo: TransactionRepositoryStub()
    )
    
    return ChestDetail()
        .environmentObject(interactor)
        .environmentObject(DI.preview)
}
