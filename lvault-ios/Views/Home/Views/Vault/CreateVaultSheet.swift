//
//  CreateVaultSheet.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/30/24.
//

import SwiftUI

struct CreateVaultSheet: View {
    @Binding var isPresented: Bool
    @State private var vaultName: String = ""
    @State private var vaultLoadable: Loadable<Vault> = .idle
    @EnvironmentObject private var vaultInteractor: VaultInteractor
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 8,
            content: {
                TextField(
                    text: $vaultName,
                    prompt: Text("Vault name...").italic()
                ) {
                    Text("")
                }.textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                switch vaultLoadable {
                case .loading:
                    ProgressView()
                case .error(let error):
                    Text("Error: \(error.localizedDescription)")
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                case .idle:
                    EmptyView()
                case .data:
                    Text("Vault successfully created").task {
                        try? await Task.sleep(for: .seconds(0.75))
                        vaultInteractor.loadVaults()
                        isPresented = false
                    }
                }
                
                Button(action: {
                    vaultInteractor.createVault(
                        .init(id: UUID().uuidString, name: vaultName, chests: [], createdAt: 0),
                        into: $vaultLoadable)
                }) {
                    Text("Confirm")
                }
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                }
            }
        ).padding()
    }
}

#Preview {
    CreateVaultSheet(isPresented: .constant(true))
}
