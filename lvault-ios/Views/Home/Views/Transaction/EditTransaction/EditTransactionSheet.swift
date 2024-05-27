//
//  EditTransactionSheet.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/27/24.
//

import SwiftUI

struct EditTransactionSheet: View {
    @Binding var isPresented: Bool
    let transaction: Transaction
    @State private var selectedLabelIds: Set<String>
    @EnvironmentObject private var transactionInteractor: TransactionInteractor
    @EnvironmentObject private var transactionLabelInteractor: TransactionLabelInteractor
    
    init(isPresented: Binding<Bool>, transaction: Transaction) {
        self._isPresented = isPresented
        self.transaction = transaction
        _selectedLabelIds = .init(initialValue: Set(transaction.labels.map(\.id)))
    }
    
    var body: some View {
        buildStateView(transactionLabelInteractor.transactionLabels)
            .onAppear {
                transactionLabelInteractor.loadTransactionLabels()
            }
    }
}

private extension EditTransactionSheet {
    @ViewBuilder
    func buildStateView(_ state: LoadableList<TransactionLabel>) -> some View {
        switch state {
        case .idle:
            EmptyView()
        case .loading:
            ProgressView()
        case .error(let error):
            Text(error.localizedDescription)
        case .data(let data):
            buildLabelList(data: data)
            VStack {
                Button(action: confirm) {
                    Text("Confirm").applySheetButtonStyle()
                }.buttonStyle(.borderedProminent)
                Button(action: { isPresented = false }) {
                    Text("Cancel").applySheetButtonStyle()
                }.buttonStyle(.bordered)
            }.padding()
        }
    }
    
    @ViewBuilder
    func buildLabelList(data: [TransactionLabel]) -> some View {
        List {
            ForEach(data, id: \.id) { label in
                TransactionLabelSelectionRow(
                    transactionLabel: label,
                    isSeleted: .init(
                        get: { selectedLabelIds.contains(label.id) },
                        set: { isSelected in
                            if isSelected {
                                selectedLabelIds.insert(label.id)
                            } else {
                                selectedLabelIds.remove(label.id)
                            }
                        }
                    )
                )
            }
        }
    }
    
    func confirm() {
        guard let allLabels = transactionLabelInteractor.transactionLabels.currentData else { return }
        
        let selectedLabels = allLabels.filter({ selectedLabelIds.contains($0.id) })
        
        transactionInteractor.updateTransaction(
            transaction,
            setTransactionLabels: selectedLabels,
            completion: {
                transactionInteractor.loadTransactions()
                isPresented = false
            }
        )
    }
}

#Preview {
    EditTransactionSheet(
        isPresented: .constant(true),
        transaction: TransactionRepositoryStub.data.first!
    )
    .environmentObject(DI.preview.container.getTransactionLabelInteractor())
    .environmentObject(DI.preview.container.getTransactionInteractor(parentChest: ChestDTO.create(vaultId: "1", name: "example chest")))
}
