//
//  VaultList.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import SwiftUI

struct VaultList: View {
    let vaults: [Vault]
    @State private var showDeleteAlert: Bool = false
    @State private var deletedVault: Vault?
    @EnvironmentObject private var vaultInteractor: VaultInteractor
    
    var body: some View {
        List {
            ForEach(vaults, id: \.id) { vault in
                NavigationLink {
                    VaultDetail()
                        .environmentObject(
                            ChestInteractor(
                                vault: vault,
                                repo: ChestRepositoryImpl(persistence: .shared)
                            )
                        )
                } label: {
                    VaultRow(vault: vault)
                }
            }.onDelete { indexSet in
                assert(indexSet.count == 1, "Only delete 1 item at a time")
                let vault = vaults[indexSet.first!]
                deletedVault = vault
                showDeleteAlert = true
            }
        }.alert(
            "Delete vault?",
            isPresented: $showDeleteAlert,
            presenting: deletedVault
        ) { vault in
            Button(role: .destructive) {
                deleteVault(vault)
            } label: {
                Text("Delete")
            }
        } message: { vault in
            Text("Delete vault [\(vault.name)]? All chests within the vault and their related transaction data will be wiped out. This action cannot be reverted!")
        }
    }
}

private extension VaultList {
    func deleteVault(_ vault: Vault) {
        vaultInteractor.deleteVault(
            vault,
            completion: { vaultInteractor.loadVaults() }
        )
    }
}

#Preview {
    let stub = VaultRepositoryStub()
    return NavigationStack {
        VaultList(vaults: stub.data)
            .environmentObject(VaultInteractor(repo: stub))
    }
}
