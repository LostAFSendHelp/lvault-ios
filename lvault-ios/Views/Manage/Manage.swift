//
//  Manage.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/23/24.
//

import SwiftUI

struct Manage: View {
    @State private var showTransactionLabelSheet: Bool = false
    @State private var editingLabel: TransactionLabel?
    @EnvironmentObject private var transactionLabelInteractor: TransactionLabelInteractor
    
    var body: some View {
        NavigationStack {
            buildStateView(transactionLabelInteractor.transactionLabels)
                .navigationTitle(Text("Manage"))
        }
        .onAppear {
            transactionLabelInteractor.loadTransactionLabels()
        }
        .tabItem { Label("Manage", systemImage: "tag.fill") }
        .sheet(isPresented: $showTransactionLabelSheet, content: {
            TransactionLabelSheet(
                isPresented: $showTransactionLabelSheet,
                intent: .create
            )
        })
        .sheet(isPresented: .constant(editingLabel != nil), content: {
            TransactionLabelSheet(
                isPresented: .init(get: { editingLabel != nil }, set: { _ in editingLabel = nil }),
                intent: .edit(editingLabel!)
            )
        })
    }
}

private extension Manage {
    @ViewBuilder
    func buildStateView(_ state: LoadableList<TransactionLabel>) -> some View {
        switch state {
        case .loading:
            ProgressView()
        case .idle:
            EmptyView()
        case .error(let error):
            Text(error.localizedDescription)
        case .data(let transactionLabels):
            if transactionLabels.isEmpty {
                Text("No Transaction labels found. Create one?")
                Button {
                    showTransactionLabelSheet = true
                } label: {
                    Text("Create")
                }
            } else {
                TransactionLabelList(
                    transactionLabels: transactionLabels,
                    editingLabel: $editingLabel,
                    onDeleteTransactionLabel: deleteTransactionLabel(_:)
                ).toolbar {
                    Button {
                        showTransactionLabelSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    func deleteTransactionLabel(_ tLabel: TransactionLabel) {
        transactionLabelInteractor.deleteTransactionLabel(
            tLabel,
            completion: { transactionLabelInteractor.loadTransactionLabels() }
        )
    }
}

#Preview {
    Manage()
        .environmentObject(DI.preview.container.getTransactionLabelInteractor())
}
