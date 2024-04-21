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
        buildStateView(vaultsLoadable)
            .onAppear(perform: {
                print("mine appear")
                vaultInteractor.loadVaults(into: $vaultsLoadable)
            })
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
            VaultList(vaults: vaults)
        }
    }
}

#Preview {
    Home()
}
