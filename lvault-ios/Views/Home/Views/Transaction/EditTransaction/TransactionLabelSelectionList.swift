//
//  TransactionLabelSelectionList.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 6/2/24.
//

import SwiftUI

struct TransactionLabelSelectionList: View {
    let transactionLabels: [TransactionLabel]
    @Binding var selectedLabelIds: Set<String>
    
    var body: some View {
        List {
            ForEach(transactionLabels, id: \.id) { label in
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
}

#Preview {
    return TransactionLabelSelectionList(
        transactionLabels: TransactionLabelRepositoryStub.data,
        selectedLabelIds: .constant([])
    )
}
