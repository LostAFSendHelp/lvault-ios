//
//  VaultDetail.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import SwiftUI

struct VaultDetail: View {
    var vault: Vault
    
    var body: some View {
        List(vault.chests, id: \.id) { chest in
            ChestRow(chest: chest)
        }
        .navigationTitle(Text(vault.name))
    }
}

#Preview {
    VaultDetail(
        vault: .create(name: "Example vault")
            .withChest(name: "Chest 1", amount: 2000)
            .withChest(name: "Chest 2", amount: 3000)
            .withChest(name: "Chest 3", amount: 4000)
            .withChest(name: "Chest 4", amount: 5000)
    )
}
