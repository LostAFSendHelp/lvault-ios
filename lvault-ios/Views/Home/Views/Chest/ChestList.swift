//
//  ChestList.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import SwiftUI

struct ChestList: View {
    let chests: [Chest]
    
    var body: some View {
        List(chests, id: \.id) { chest in
            NavigationLink {
                ChestDetail()
                    .environmentObject(TransactionInteractor(
                        chest: chest,
                        repo: TransactionRepositoryImpl(persistence: .shared)
                    ))
            } label: {
                ChestRow(chest: chest)
            }
        }
    }
}

#Preview {
    ChestList(chests: [])
}
