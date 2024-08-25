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
        VStack(alignment: .leading) {
            HStack {
                TransactionAmountText(amount: transaction.amount)
                
                if transaction.isTransfer {
                    if transaction.amount < 0 {
                        Image(systemName: "arrow.up.right.circle").foregroundStyle(.red)
                    } else {
                        Image(systemName: "arrow.down.left.circle").foregroundStyle(.green)
                    }
                }
                
                Spacer()
                Text(transaction.timeText).font(.system(size: 14)).foregroundStyle(.secondary)
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
            
            if let note = transaction.note {
                Text("_**Note**: \(note)_")
                    .font(.system(size: 12))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .padding(.top, transaction.labels.isEmpty ? 0.1 : 0) // 0.1: magic number to force the text out of amountText's bounds
            }
        }.padding(.vertical, increasedPaddings ? 8 : 0)
    }
}

#Preview {
    List { TransactionRow(transaction: TransactionRepositoryStub.data.first!.withLabels(4)) }
}
