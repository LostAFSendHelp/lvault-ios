//
//  TransactionRow.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import SwiftUI

struct TransactionRow: View {
    var transaction: Transaction
    
    private var increasedPaddings: Bool {
        return !transaction.labels.isEmpty
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(transaction.amountText)
                    .foregroundStyle(transaction.amount < 0 ? .red : .green)
                Spacer()
                Text(transaction.timeText)
            }
            
            if transaction.labels.isEmpty {
                EmptyView()
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(content: {
                        Spacer(minLength: 40).frame(minHeight: 28) // cheat to counter -40 hPadding
                        ForEach(
                            transaction.labels.sorted(by: { left, right in left.name < right.name }),
                            id: \.id
                        ) { label in
                            LabelView(text: label.name, color: label.color.color)
                        }
                        Spacer(minLength: 40)
                    })
                }
                .scrollIndicators(.hidden)
                .clipShape(.rect)
                .padding(.horizontal, -40) // cheat to prevent labels being clipped horizontally
            }
        }.padding(.vertical, increasedPaddings ? 8 : 0)
    }
}

#Preview {
    List { TransactionRow(transaction: TransactionRepositoryStub.data.first!.withLabels(4)) }
}
