//
//  Home.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/19/24.
//

import SwiftUI
import CoreData

struct Home: View {
    @State private var showCreateVaultSheet: Bool = false
    @EnvironmentObject private var vaultInteractor: VaultInteractor
    
    var body: some View {
        NavigationStack {
            buildStateView(vaultInteractor.vaults)
                .onAppear {
                    vaultInteractor.loadVaults()
                }
                .navigationTitle(Text("Vaults"))
                .sheet(isPresented: $showCreateVaultSheet) {
                    CreateVaultSheet(isPresented: $showCreateVaultSheet)
                }
        }.tabItem { Label("Home", systemImage: "house.fill") }
    }
}

private extension Home {
    @ViewBuilder
    func buildStateView(_ state: LoadableList<Vault>) -> some View {
        switch state {
        case .loading:
            ProgressView()
        case .error(let error):
            Text(error.localizedDescription)
        case .data(let vaults):
            if vaults.isEmpty {
                Text("No vaults found. Create one?")
                Button(action: {
                    showCreateVaultSheet = true
                }) {
                    Text("Create")
                }
            } else {
                VaultList(
                    vaults: vaults,
                    onDeleteVault: deleteVault(_:)
                )
                .toolbar {
                    Button(action: {
                        showCreateVaultSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        default:
            EmptyView()
        }
    }
    
    func deleteVault(_ vault: Vault) {
        vaultInteractor.deleteVault(
            vault,
            completion: { vaultInteractor.loadVaults() }
        )
    }
}

#Preview {
    Home()
        .environmentObject(VaultInteractor(repo: VaultRepositoryStub()))
        .dependency(.preview)
}
