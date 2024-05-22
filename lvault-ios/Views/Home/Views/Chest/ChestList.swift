//
//  ChestList.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import SwiftUI

struct ChestList: View {
    let chests: [Chest]
    let parentVaultName: String
    let onDeleteChest: VoidHandler<Chest>
    @State private var showDeleteAlert: Bool = false
    @State private var deletedChest: Chest?
    
    var body: some View {
        List {
            ForEach(chests, id: \.id) { chest in
                NavigationLink {
                    ChestDetail()
                        .environmentObject(TransactionInteractor(
                            chest: chest,
                            repo: TransactionRepositoryImpl(persistence: .shared)
                        ))
                } label: {
                    ChestRow(chest: chest)
                }
            }.onDelete { indexSet in
                assert(indexSet.count == 1, "Only delete 1 item at a time")
                let chest = chests[indexSet.first!]
                deletedChest = chest
                showDeleteAlert = true
            }
        }.alert(
            "Delete chest?",
            isPresented: $showDeleteAlert,
            presenting: deletedChest
        ) { chest in
            Button(role: .destructive) {
                onDeleteChest(chest)
            } label: {
                Text("Delete")
            }
        } message: { chest in
            Text("Delete chest [\(chest.name)] from vault [\(parentVaultName)]? All transaction data within this chest will be wiped out. This action cannot be reverted!")
        }
    }
}

#Preview {
    let stub = ChestRepositoryStub()
    
    return NavigationStack {
        ChestList(
            chests: stub.data,
            parentVaultName: "Example vault",
            onDeleteChest: { _ in }
        )
    }
}
