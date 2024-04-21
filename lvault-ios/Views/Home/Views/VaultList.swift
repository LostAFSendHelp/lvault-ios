//
//  VaultList.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import SwiftUI

struct VaultList: View {
    let vaults: [Vault]
    
    var body: some View {
        List(vaults) { vault in
            VaultRow(vault: vault)
        }
    }
}

#Preview {
    VaultList(vaults: VaultRepositoryStub.data.map({ .init(id: $0.id, name: $0.name) }))
}
