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
        }.padding()
    }
}

#Preview {
    let vault = Vault(id: "id", name: "vault")
    return VaultRow(vault: vault)
}
