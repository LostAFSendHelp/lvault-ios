//
//  TransactionRow.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import SwiftUI

struct TransactionRow: View {
    var transaction: Transaction
    
    var body: some View {
        HStack {
            Text(transaction.amountText)
                .foregroundStyle(transaction.amount < 0 ? .red : .green)
            Spacer()
            Text(transaction.dateText)
        }
    }
}

#Preview {
    TransactionRow(transaction: .init(
        id: "",
        amount: 1000000,
        transactionDate: Date.now.millisecondsSince1970,
        labels: [], // TODO: implement transaction labels
        createdAt: Date.now.millisecondsSince1970
    ))
}
