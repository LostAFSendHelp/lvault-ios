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
            spacing: UIConfigs.verticalSpacing,
            content: {
                TextField(
                    text: $vaultName,
                    prompt: Text("Vault name...").italic()
                ) {
                    Text("")
                }.applyBasicInputStyle()
                
                buildStateView(vaultLoadable)
                
                Button(action: {
                    vaultInteractor.createVault(
                        named: vaultName,
                        into: $vaultLoadable
                    )
                }) {
                    Text("Confirm").applySheetButtonStyle()
                }.buttonStyle(.borderedProminent)
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel").applySheetButtonStyle()
                }.buttonStyle(.bordered)
            }
        ).padding()
    }
}

private extension CreateVaultSheet {
    @ViewBuilder
    func buildStateView(_ state: Loadable<Vault>) -> some View {
        switch state {
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
    }
}

#Preview {
    CreateVaultSheet(isPresented: .constant(true))
        .environmentObject(VaultInteractor(repo: VaultRepositoryStub()))
}
