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
                Text(transaction.amountText).font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(transaction.amount < 0 ? .red : .green)
                Spacer()
                Text(transaction.timeText).font(.system(size: 14)).foregroundStyle(.gray)
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
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.gray)
                    .lineLimit(2)
            }
        }.padding(.vertical, increasedPaddings ? 8 : 0)
    }
}

#Preview {
    List { TransactionRow(transaction: TransactionRepositoryStub.data.first!.withLabels(4)) }
}
