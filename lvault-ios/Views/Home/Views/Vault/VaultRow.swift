//
//  VaultRow.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import SwiftUI

struct VaultRow: View {
    var vault: Vault
    
    var body: some View {
        HStack {
            Text(vault.name)
            Spacer()
        }
    }
}

#Preview {
    let vault = VaultDTO(id: "id", name: "vault", chests: [], createdAt: 0)
    return VaultRow(vault: vault)
}
