//
//  VaultDetail.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import SwiftUI

struct VaultDetail: View {
    @State private var showCreateChestSheet = false
    @EnvironmentObject private var chestInteractor: ChestInteractor
    
    var body: some View {
        buildStateView(chestInteractor.chests)
            .onAppear {
                chestInteractor.loadChests()
            }
            .navigationTitle(Text(chestInteractor.parentVaultName))
            .toolbar {
                Button {
                    showCreateChestSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }.sheet(
                isPresented: $showCreateChestSheet,
                content: {
                    CreateChestSheet(isPresented: $showCreateChestSheet)
                        .environmentObject(chestInteractor)
                }
            )
    }
}

private extension VaultDetail {
    @ViewBuilder
    func buildStateView(_ state: LoadableList<Chest>) -> some View {
        switch state {
        case .data(let chests):
            ChestList(chests: chests)
        case .error(let error):
            Text(error.localizedDescription)
        case .loading:
            ProgressView()
        default:
            EmptyView()
        }
    }
}

#Preview {
    let vault = Vault.create(name: "Example vault")
        .withChest(name: "Chest 1", amount: 2000)
        .withChest(name: "Chest 2", amount: 3000)
        .withChest(name: "Chest 3", amount: 4000)
        .withChest(name: "Chest 4", amount: 5000)
    let chestInteractor = ChestInteractor(
        vault: vault,
        repo: ChestRepositoryImpl(persistence: .preview)
    )
    return VaultDetail().environmentObject(chestInteractor)
}
