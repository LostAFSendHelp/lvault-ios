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
            Text(String(chest.currentAmount))
        }
    }
}

#Preview {
    List {
        ChestRow(chest: ChestRepositoryStub.data.first!)
    }
}
