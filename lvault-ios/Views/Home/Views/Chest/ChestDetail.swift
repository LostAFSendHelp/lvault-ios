//
//  ChestDetail.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import SwiftUI

struct ChestDetail: View {
    @State private var showCreateTransactionSheet = false
    @EnvironmentObject private var transactionInteractor: TransactionInteractor
    
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
                    .environmentObject(transactionInteractor)
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
                parentChestName: transactionInteractor.parentChestName
            )
        case .error(let error):
            Text(error.localizedDescription)
        case .loading:
            ProgressView()
        default:
            EmptyView()
        }
    }
}

#Preview {
    let interactor: TransactionInteractor = .init(
        chest: ChestDTO.create(vaultId: "1", name: "Example chest"),
        repo: TransactionRepositoryStub()
    )
    
    return ChestDetail().environmentObject(interactor)
}
