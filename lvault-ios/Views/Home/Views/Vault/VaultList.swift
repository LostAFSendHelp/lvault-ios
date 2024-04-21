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
        List(vaults, id: \.id) { vault in
            NavigationLink {
                VaultDetail(vault: vault)
            } label: {
                VaultRow(vault: vault)
            }
        }
    }
}

#Preview {
    VaultList(vaults: VaultRepositoryStub.data)
}
