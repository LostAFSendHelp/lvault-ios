//
//  SelectTransactionLabelsSheet.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/27/24.
//

import SwiftUI

struct SelectTransactionLabelsSheet: View {
    let onConfirm: VoidHandler<[TransactionLabel]>
    
    @Binding var isPresented: Bool
    @State private var selectedLabelIds: Set<String>
    @EnvironmentObject private var transactionLabelInteractor: TransactionLabelInteractor
    
    init(
        isPresented: Binding<Bool>,
        selectedLabels: [TransactionLabel],
        onConfirm: @escaping VoidHandler<[TransactionLabel]>
    ) {
        self._isPresented = isPresented
        self.onConfirm = onConfirm
        _selectedLabelIds = .init(initialValue: Set(selectedLabels.map(\.id)))
    }
    
    var body: some View {
        buildStateView(transactionLabelInteractor.transactionLabels)
            .onAppear {
                transactionLabelInteractor.loadTransactionLabels()
            }
    }
}

private extension SelectTransactionLabelsSheet {
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
            TransactionLabelSelectionList(
                transactionLabels: data,
                selectedLabelIds: $selectedLabelIds
            )
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
    
    func confirm() {
        guard let allLabels = transactionLabelInteractor.transactionLabels.currentData else { return }
        
        let selectedLabels = allLabels.filter({ selectedLabelIds.contains($0.id) })
        onConfirm(selectedLabels)
    }
}

#Preview {
    SelectTransactionLabelsSheet(
        isPresented: .constant(true),
        selectedLabels: [],
        onConfirm: { _ in }
    )
    .environmentObject(DI.preview.container.getTransactionLabelInteractor())
}
