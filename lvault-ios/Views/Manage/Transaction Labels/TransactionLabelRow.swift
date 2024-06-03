//
//  TransactionLabelRow.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/25/24.
//

import SwiftUI

struct LabelView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .padding(.vertical, 5)
            .padding(.horizontal, 14)
            .foregroundStyle(color)
            .background(color.opacity(0.2))
            .background(.white)
            .cornerRadius(16)
            .roundedBorder(cornerRadius: 16, color: color)
            .padding(.vertical, 3)
    }
}

struct TransactionLabelRow: View {
    let transactionLabel: TransactionLabel
    @Binding var editingLabel: TransactionLabel?
    
    var body: some View {
        HStack {
            LabelView(text: transactionLabel.name, color: transactionLabel.color.color)
        }.contextMenu {
            Button(action: { editingLabel = transactionLabel }) {
                Label("Edit", systemImage: "square.and.pencil")
            }
        }
    }
}

#Preview {
    List {
        TransactionLabelRow(
            transactionLabel: TransactionLabelRepositoryStub.data.first!,
            editingLabel: .constant(nil)
        )
        
    }.listStyle(.grouped)
}
