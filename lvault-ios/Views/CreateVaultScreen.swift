//
//  CreateVaultScreen.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 07/01/2024.
//

import SwiftUI

struct CreateVaultScreen: View {
    @State private var vaultName: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Text(String.Presets.onboardingCreateVault)
                .multilineTextAlignment(.center)
                .padding(16)
            
            TextField("Enter a nice name for your vault", text: $vaultName)
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .trailing], 16)
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.system(size: 12).italic())
            }
            
            Button(
                action: {
                    if !Self.validateName(vaultName) {
                        errorMessage = .Presets.vaultNameEmptyError
                    } else {
                        errorMessage = nil
                        vaultName = vaultName.trimmed
                    }
                },
                label: {
                    Text(String.Presets.confirm)
                }
            )
            .buttonStyle(.bordered)
            .padding([.top], 16)
        }
    }
    
    private static func validateName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    CreateVaultScreen()
}
