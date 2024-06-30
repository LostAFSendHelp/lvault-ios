//
//  VaultDetail.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import SwiftUI

struct VaultDetail: View {
    @State private var showCreateChestSheet = false
    @State private var showCreateTransferSheet = false
    @EnvironmentObject private var chestInteractor: ChestInteractor
    
    var body: some View {
        buildStateView(chestInteractor.chests)
            .onAppear {
                chestInteractor.loadChests()
            }
            .navigationTitle(Text(chestInteractor.parentVaultName))
            .toolbar {
                if chestInteractor.chests.currentData?.count ?? 0 > 1 {
                    Button {
                        showCreateTransferSheet = true
                    } label: {
                        Image(systemName: "arrow.left.arrow.right")
                    }
                }
                
                Button {
                    showCreateChestSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(
                isPresented: $showCreateChestSheet,
                content: {
                    CreateChestSheet(isPresented: $showCreateChestSheet)
                }
            )
            .sheet(
                isPresented: $showCreateTransferSheet,
                content: {
                    CreateTransferSheet(isPresented: $showCreateTransferSheet)
                }
            )
    }
}

private extension VaultDetail {
    @ViewBuilder
    func buildStateView(_ state: LoadableList<Chest>) -> some View {
        switch state {
        case .data(let chests):
            ZStack(alignment: .bottomTrailing) {
                ChestList(
                    chests: chests,
                    parentVaultName: chestInteractor.parentVaultName,
                    onDeleteChest: deleteChest(_:)
                )
                Text("Balance: \(chestInteractor.parentVaultBalance)")
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .padding()
            }
        case .error(let error):
            Text(error.localizedDescription)
        case .loading:
            ProgressView()
        default:
            EmptyView()
        }
    }
    
    func deleteChest(_ chest: Chest) {
        chestInteractor.deleteChest(
            chest,
            completion: { chestInteractor.loadChests() }
        )
    }
}

#Preview {
    let vault = VaultRepositoryStub.data.first!
    let chestInteractor = ChestInteractor(
        vault: vault,
        repo: ChestRepositoryStub()
    )
    
    return NavigationStack {
        VaultDetail().environmentObject(chestInteractor)
            .dependency(.preview)
    }
}
