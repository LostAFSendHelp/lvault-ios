//
//  TransactionLabelSelectionRow.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/27/24.
//

import SwiftUI

struct TransactionLabelSelectionRow: View {
    let transactionLabel: TransactionLabel
    @Binding var isSeleted: Bool
    
    var body: some View {
        Button(action: { isSeleted.toggle() }) {
            HStack {
                LabelView(text: transactionLabel.name, color: transactionLabel.color.color)
                if isSeleted {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

#Preview {
    List {
        TransactionLabelSelectionRow(
            transactionLabel: TransactionLabelRepositoryStub.data.first!,
            isSeleted: .constant(false)
        )
    }
}
