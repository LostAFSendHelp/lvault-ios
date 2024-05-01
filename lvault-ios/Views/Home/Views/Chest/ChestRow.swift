//
//  ChestRow.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import SwiftUI

struct ChestRow: View {
    var chest: Chest
    
    var body: some View {
        HStack {
            Text(chest.name)
            Spacer()
            Text(String(chest.initialAmount))
        }
    }
}

#Preview {
    ChestRow(chest: .init(
        id: "",
        name: "example chest",
        initialAmount: 300,
        transactions: [],
        createdAt: 0
    ))
}
