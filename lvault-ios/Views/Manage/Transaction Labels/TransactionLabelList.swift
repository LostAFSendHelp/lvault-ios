//
//  TransactionLabelList.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/25/24.
//

import SwiftUI

struct TransactionLabelList: View {
    let transactionLabels: [TransactionLabel]
    @Binding var editingLabel: TransactionLabel?
    let onDeleteTransactionLabel: VoidHandler<TransactionLabel>
    @State private var showDeleteAlert: Bool = false
    @State private var deletedTransactionLabel: TransactionLabel?
    
    var body: some View {
        List {
            ForEach(transactionLabels, id: \.id) { label in
                TransactionLabelRow(transactionLabel: label, editingLabel: $editingLabel)
            }.onDelete { indexSet in
                assert(indexSet.count == 1, "Only delete 1 item at a time")
                let tLabel = transactionLabels[indexSet.first!]
                deletedTransactionLabel = tLabel
                showDeleteAlert = true
            }
        }.alert(
            "Delete Transaction label?",
            isPresented: $showDeleteAlert,
            presenting: deletedTransactionLabel
        ) { label in
            Button(role: .destructive) {
                onDeleteTransactionLabel(label)
            } label: {
                Text("Delete")
            }
        } message: { label in
            Text("Delete Transaction label [\(label.name)]? All transactions in all vaults and chests will no longer have access to this label. This action cannot be reverted!")
        }
    }
}

#Preview {
    TransactionLabelList(
        transactionLabels: TransactionLabelRepositoryStub.data,
        editingLabel: .constant(nil),
        onDeleteTransactionLabel: { _ in }
    )
}
