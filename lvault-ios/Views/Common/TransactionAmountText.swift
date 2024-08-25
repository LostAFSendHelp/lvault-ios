//
//  TransactionAmountText.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/25/24.
//

import SwiftUI

struct TransactionAmountText: View {
    let amount: Double
    
    var body: some View {
        Text(amount.signedDecimalText)
            .font(.system(size: 22, weight: .heavy))
            .foregroundStyle(amount < 0 ? .red : .green)
    }
}
