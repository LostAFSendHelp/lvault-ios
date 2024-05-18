//
//  CreateChestSheet.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/1/24.
//

import SwiftUI

struct CreateChestSheet: View {
    @Binding var isPresented: Bool
    @State private var chestLoadable: Loadable<Chest> = .idle
    @State private var chestName: String = ""
    @State private var chestInitialAmount: Double?
    @EnvironmentObject private var chestInteractor: ChestInteractor
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 16,
            content: {
                TextField(
                    text: $chestName,
                    prompt: Text("Chest name...").italic()
                ) {
                    Text("")
                }.textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                TextField(
                    value: $chestInitialAmount,
                    format: .number,
                    prompt: Text("Initial amount...").italic()
                ) {
                    Text("")
                }.textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .keyboardType(.numberPad)
                
                buildStateView(chestLoadable)
                
                Button(action: {
                    guard let chestInitialAmount else {
                        chestLoadable = .error(LVaultError.custom("Initial amount is required"))
                        return
                    }
                    
                    chestInteractor.createChest(
                        named: chestName,
                        initialAmount: chestInitialAmount,
                        into: $chestLoadable
                    )
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

private extension CreateChestSheet {
    @ViewBuilder
    func buildStateView(_ state: Loadable<Chest>) -> some View {
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
            Text("Chest successfully created").task {
                try? await Task.sleep(for: .seconds(0.75))
                chestInteractor.loadChests()
                isPresented = false
            }
        }
    }
}

#Preview {
    CreateChestSheet(isPresented: .constant(true))
}