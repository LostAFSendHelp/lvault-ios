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
        NavigationSplitView {
            buildStateView(vaultInteractor.vaults)
                .onAppear {
                    vaultInteractor.loadVaults()
                }
                .navigationTitle(Text("Vaults"))
                .sheet(isPresented: $showCreateVaultSheet) {
                    CreateVaultSheet(isPresented: $showCreateVaultSheet)
                }.toolbar {
                    Button(action: {
                        showCreateVaultSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
        } detail: {
            Text("Vault details here")
        }
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
                VaultList(vaults: vaults)
            }
        default:
            EmptyView()
        }
    }
}

#Preview {
    Home().environmentObject(VaultInteractor(repo: VaultRepositoryImpl(persistence: .preview)))
}
