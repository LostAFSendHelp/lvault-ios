//
//  CreateTransactionSheet.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/18/24.
//

import SwiftUI

struct CreateTransactionSheet: View {
    @Binding var isPresented: Bool
    @State private var transactionLoadable: Loadable<Transaction> = .idle
    @State private var amount: Double?
    @State private var date: Date = .now
    @State private var isExpense: Bool = false
    @EnvironmentObject private var interactor: TransactionInteractor
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: UIConfigs.verticalSpacing
        ) {
            TextField(
                value: $amount,
                format: .number
            ) {
                Text("transaction amount...").italic()
            }.applyBasicInputStyle().keyboardType(.decimalPad)
            
            Button(action: {
                isExpense.toggle()
            }, label: {
                HStack {
                    Image(systemName: isExpense ? "checkmark.square.fill" : "square")
                    Text("Is expense")
                }
            })
            
            DatePicker(
                "Date & time",
                selection: $date,
                displayedComponents: [.date, .hourAndMinute]
            )
            
            buildStateView(transactionLoadable)
            
            Button(action: {
                guard let amount else {
                    transactionLoadable = .error(LVaultError.custom("Transaction amount missing"))
                    return
                }
                
                interactor.createTransaction(
                    amount: amount * (isExpense ? -1 : 1),
                    date: date.millisecondsSince1970,
                    into: $transactionLoadable
                )
            }, label: {
                Text("Confirm").applySheetButtonStyle()
            }).buttonStyle(.borderedProminent)
            
            Button(action: {
                isPresented = false
            }, label: {
                Text("Cancel").applySheetButtonStyle()
            }).buttonStyle(.bordered)
        }.padding()
    }
}

private extension CreateTransactionSheet {
    @ViewBuilder
    func buildStateView(_ state: Loadable<Transaction>) -> some View {
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
            Text("Transaction successfully created").task {
                try? await Task.sleep(for: .seconds(0.75))
                interactor.loadTransactions()
                isPresented = false
            }
        }
    }
}

#Preview {
    CreateTransactionSheet(isPresented: .constant(true))
        .environmentObject(
            TransactionInteractor(
                chest: ChestRepositoryStub.data.first!,
                repo: TransactionRepositoryStub()
            )
        )
}
