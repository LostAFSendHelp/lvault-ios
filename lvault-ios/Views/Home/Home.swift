//
//  Home.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/19/24.
//

import SwiftUI
import CoreData

struct Home: View {
    @State private var vaultsLoadable: Loadable<[Vault]> = .loading
    @Environment(\.vaultInteractor) var vaultInteractor: VaultInteractor
    
    var body: some View {
        NavigationSplitView {
            buildStateView(vaultsLoadable)
                .onAppear(perform: {
                    vaultInteractor.loadVaults(into: $vaultsLoadable)
                })
                .navigationTitle(Text("Vaults"))
        } detail: {
            Text("Vault details here")
        }
    }
}

private extension Home {
    @ViewBuilder
    func buildStateView(_ state: Loadable<[Vault]>) -> some View {
        switch vaultsLoadable {
        case .loading:
            ProgressView()
        case .error(let error):
            Text(error.localizedDescription)
        case .data(let vaults):
            if vaults.isEmpty {
                Text("No vaults found. Create one?")
                Button(action: { }) {
                    Text("Create")
                }
            } else {
                VaultList(vaults: vaults)
            }
        }
    }
}

#Preview {
    Home().environment(\.vaultInteractor, VaultInteractorImpl(repo: VaultRepositoryImpl(persistence: .preview)))
}
