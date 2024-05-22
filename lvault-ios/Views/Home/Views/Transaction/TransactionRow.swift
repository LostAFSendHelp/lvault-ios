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
            Text(transaction.timeText)
        }
    }
}

#Preview {
    List { TransactionRow(transaction: TransactionRepositoryStub.data.first!) }
}
