//
//  TransactionList.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import SwiftUI

struct TransactionList: View {
    var transactions: [Transaction]
    var body: some View {
        List(transactions, id: \.id) { transaction in
            TransactionRow(transaction: transaction)
        }
    }
}

#Preview {
    TransactionList(transactions: TransactionRepositoryStub.transactions)
}
