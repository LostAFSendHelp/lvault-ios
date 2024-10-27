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
    @State private var editingTransactionNote: Transaction?
    @State private var transactionAscendingByDate: Bool = false
    @State private var searchText: String = ""
    @EnvironmentObject private var transactionInteractor: TransactionInteractor
    @EnvironmentObject private var di: DI
    
    private var showEditLabelsSheet: Binding<Bool> {
        .init(
            get: { editingTransaction != nil },
            set: { _ in editingTransaction = nil }
        )
    }
    
    private var showEditNoteSheet: Binding<Bool> {
        .init(
            get: { editingTransactionNote != nil },
            set: { _ in editingTransactionNote = nil }
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
            }.sheet(isPresented: showEditLabelsSheet) {
                SelectTransactionLabelsSheet(
                    isPresented: showEditLabelsSheet,
                    selectedLabels: editingTransaction!.labels,
                    onConfirm: { labels in
                        updateTransaction(editingTransaction!, setTransactionLabels: labels)
                    }
                )
                .environmentObject(di.container.getTransactionLabelInteractor())
            }.sheet(isPresented: showEditNoteSheet) {
                EditNoteSheet(
                    isPresented: showEditNoteSheet,
                    note: editingTransactionNote!.note,
                    onConfirm: { note in
                        updateTransaction(editingTransactionNote!, setNote: note)
                    }
                )
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
                    transactions: transactions.filterByAttributesIgnoringDiacritics(
                        keyPath: \.searchAttributes,
                        text: searchText
                    ),
                    parentChestName: transactionInteractor.parentChestName,
                    ascendingByDate: $transactionAscendingByDate,
                    editingTransaction: $editingTransaction,
                    editingTransactionNote: $editingTransactionNote,
                    searchText: .init(
                        get: { searchText },
                        set: { text in
                            guard text.trimmed != searchText.trimmed else { return }
                            let newValue = text.count > 2 ? text : ""
                            searchText = newValue
                        }
                    ),
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
    
    func updateTransaction(
        _ transaction: Transaction,
        setNote note: String?
    ) {
        transactionInteractor.updateTransaction(
            editingTransactionNote!,
            setNote: note,
            completion: {
                transactionInteractor.loadTransactions()
                editingTransactionNote = nil
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
