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
    @State private var transactionAscendingByDate: Bool = false
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
                    transactionAscendingByDate.toggle()
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                Button {
                    showCreateTransactionSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }.sheet(isPresented: $showCreateTransactionSheet) {
                CreateTransactionSheet(isPresented: $showCreateTransactionSheet)
            }.sheet(isPresented: showEditSheet) {
                SelectTransactionLabelsSheet(
                    isPresented: showEditSheet,
                    selectedLabels: editingTransaction!.labels,
                    onConfirm: { labels in
                        updateTransaction(editingTransaction!, setTransactionLabels: labels)
                    }
                )
                .environmentObject(di.container.getTransactionLabelInteractor())
            }
    }
}

private extension ChestDetail {
    @ViewBuilder
    func buildStateView(_ state: LoadableList<Transaction>) -> some View {
        switch state {
        case .data(let transactions):
            ZStack(alignment: .bottomTrailing) {
                TransactionList(
                    transactions: transactions,
                    parentChestName: transactionInteractor.parentChestName,
                    ascendingByDate: $transactionAscendingByDate,
                    editingTransaction: $editingTransaction,
                    onDeleteTransaction: deleteTransaction(_:)
                )
                Text("Balance: \(transactionInteractor.parentChestBalance)")
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .padding()
            }
        case .error(let error):
            Text(error.localizedDescription)
        case .loading:
            ProgressView()
        default:
            EmptyView()
        }
    }
    
    func updateTransaction(
        _ transaction: Transaction,
        setTransactionLabels labels: [TransactionLabel]
    ) {
        transactionInteractor.updateTransaction(
            editingTransaction!,
            setTransactionLabels: labels,
            completion: {
                transactionInteractor.loadTransactions()
                editingTransaction = nil
            }
        )
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
    
    return NavigationStack {
        ChestDetail()
            .environmentObject(interactor)
            .environmentObject(DI.preview)
    }
}
