//
//  CreateTransferSheet.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 6/30/24.
//

import SwiftUI

struct CreateTransferSheet: View {
    @State private var selection: String?
    @State private var from: Chest?
    @State private var to: Chest?
    @State private var date: Date = .init()
    @State private var amount: Double?
    @State private var note: String?
    @State private var resultLoadable: Loadable<Void> = .idle
    @Binding var isPresented: Bool
    @EnvironmentObject private var chestInteractor: ChestInteractor
    
    var body: some View {
        buildStateView(chestInteractor.chests)
            .onAppear(perform: {
                chestInteractor.loadChests()
            })
            .padding()
    }
}

private extension CreateTransferSheet {
    @ViewBuilder
    func buildStateView(_ state: LoadableList<Chest>) -> some View {
        switch state {
        case .loading:
            ProgressView()
        case .idle:
            EmptyView()
        case .data(let chests):
            if chests.count < 2 {
                Text("Cannot perform transfers without at least 2 chests")
                    .applyInfoTextStyle()
            } else {
                buildBody(chests: chests)
            }
        case .error(let error):
            Text("Error: \(error.localizedDescription)")
                .applyErrorTextStyle()
        }
    }
    
    @ViewBuilder
    func buildBody(chests: [Chest]) -> some View {
        VStack(spacing: 4) {
            Text("Create a Transfer")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            buildSelectionView(
                title: "From",
                chests: chests,
                selection: Binding(
                    get: { from?.id },
                    set: { value in
                        guard let value else { from = nil; return }
                        from = chests.first(where: \.id, equals: value)
                        to = nil
                    }
                ),
                excluding: nil
            )
            
            buildSelectionView(
                title: "To",
                chests: chests,
                selection: Binding(
                    get: { to?.id },
                    set: { value in
                        guard let value else { to = nil; return }
                        to = chests.first(where: \.id, equals: value)
                    }
                ),
                excluding: from?.id
            )
            
            DatePicker("Transfer date:", selection: $date)
            
            HStack {
                Text("Amount: ")
                TextField(
                    value: $amount,
                    format: .number
                ) {
                    Text("transaction amount...").italic()
                }
                .applyBasicInputStyle()
                .keyboardType(.decimalPad)
            }.padding(.top, 20)
            
            if let from, let to, let amount {
                Text("**Summary**: Transfering **\(amount.decimalText)** from **[\(from.name)]** to **[\(to.name)]**")
                    .padding(.top, 20)
            }
            
            TextView(title: "Add a note", text: $note)
                .frame(height: 120)
                .padding(.top, 16)
            
            buildStatusIndicator(state: resultLoadable)
                .padding(.top, 20)
            
            Button(action: {
                guard let from, let to, let amount else {
                    resultLoadable = .error(LVaultError.custom("From, To and Amount are required fields"))
                    return
                }
                
                chestInteractor.transfer(
                    from: from,
                    to: to,
                    amount: amount,
                    at: date.millisecondsSince1970,
                    note: note,
                    into: $resultLoadable
                )
            }, label: {
                Text("Confirm").applySheetButtonStyle()
            })
            .buttonStyle(.borderedProminent)
            .padding(.top, 24)
            
            Button(action: {
                isPresented = false
            }, label: {
                Text("Cancel").applySheetButtonStyle()
            })
            .buttonStyle(.bordered)
        }
    }
    
    @ViewBuilder
    func buildSelectionView(
        title: String,
        chests: [Chest],
        selection: Binding<String?>,
        excluding excludedId: String?
    ) -> some View {
        HStack {
            Text(title + ":")
            Picker("", selection: selection) {
                Text("Select chest").tag(nil as String?)
                ForEach(chests.removingAll(where: \.id, equals: excludedId), id: \.id) { chest in
                    Text(chest.name).tag(Optional(chest.id))
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    func buildStatusIndicator(state: Loadable<Void>) -> some View {
        switch state {
        case .data:
            Text("Transfer successfully created!")
                .applyInfoTextStyle()
                .task {
                    try? await Task.sleep(for: .seconds(0.75))
                    chestInteractor.loadChests()
                    isPresented = false
                }
        case .error(let error):
            Text(error.localizedDescription)
                .applyErrorTextStyle()
        case .loading:
            ProgressView()
        default:
            EmptyView()
        }
    }
}

#Preview {
    let vault = VaultRepositoryStub.data.first!
    let container: DIContainer = DI.preview.container
    return CreateTransferSheet(isPresented: .constant(true))
        .environmentObject(container.getChestInteractor(parentVault: vault))
}
