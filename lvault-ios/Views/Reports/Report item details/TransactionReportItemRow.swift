//
//  TransactionReportItemRow.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/25/24.
//

import SwiftUI

struct TransactionReportItem {
    let transactionId: String
    let amount: Double
    let transactionDate: Double
    let chestName: String
    let note: String?
}

struct TransactionReportItemRow: View {
    let transactionReportItem: TransactionReportItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack() {
                TransactionAmountText(amount: transactionReportItem.amount)
                Spacer()
                Text(transactionReportItem.chestName)
            }
            
            HStack {
                Text(transactionReportItem.transactionDate.millisecondToDate.HHmmGMT)
                Spacer()
                Text(transactionReportItem.transactionDate.millisecondToDate.eeeddMMyyyy)
            }
            .foregroundStyle(.secondary)
            
            if let note = transactionReportItem.note {
                Text("_**Note**: \(note)_")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    List {
        TransactionReportItemRow(transactionReportItem: .init(
            transactionId: "1",
            amount: 1000000,
            transactionDate: Date().millisecondsSince1970,
            chestName: "Preview chest",
            note: nil
        ))
        TransactionReportItemRow(transactionReportItem: .init(
            transactionId: "2",
            amount: -900000,
            transactionDate: Date().addingTimeInterval(60 * 60 * 24).millisecondsSince1970,
            chestName: "Another preview chest",
            note: "here is a note"
        ))
    }
}
