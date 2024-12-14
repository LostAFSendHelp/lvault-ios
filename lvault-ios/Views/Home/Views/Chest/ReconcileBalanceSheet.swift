//
//  ReconcileBalanceSheet.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 12/14/24.
//

import SwiftUI

struct ReconcileBalanceSheet: View {
    @Binding var isPresented: Bool
    @State private var actualBalance: Double?
    @State private var note: String?
    @State private var transactionDate: Date = .now
    @State private var transactionLoadable: Loadable<Transaction> = .idle
    @EnvironmentObject private var interactor: TransactionInteractor
    
    private var reportedAmount: Double { interactor.parentChestBalance }
    private var transactionAmount: Double? { actualBalance.map({ $0 - reportedAmount }) }
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: UIConfigs.verticalSpacing
        ) {
            Text("Reconcile balance")
                .font(.largeTitle.bold())
                .padding(.bottom, 20)
            
            HStack {
                Text("Actual balance:")
                TextField(
                    value: $actualBalance,
                    format: .number
                ) {
                    Text("How much you actually have").italic()
                }
                .applyBasicInputStyle()
                .keyboardType(.decimalPad)
            }
            
            HStack {
                Text("Reported balance:")
                TextField(
                    value: .constant(reportedAmount),
                    format: .number
                ) { Text ("") }.applyBasicInputStyle().disabled(true)
            }
            
            HStack {
                Text("Transaction amount:")
                TextField(
                    value: .constant(transactionAmount),
                    format: .number
                ) { Text("Amount to reconcile").italic() }.applyBasicInputStyle().disabled(true)
            }
            
            DatePicker(
                selection: $transactionDate,
                label: { Text("Reconciled at") }
            )
            
            TextView(
                title: "Reconciliation note",
                text: $note
            )
            .frame(height: 120)
            .padding(.bottom)
            
            buildStateView(transactionLoadable)
            
            Button(action: {
                guard let transactionAmount else {
                    transactionLoadable = .error(LVaultError.custom("Transaction amount missing"))
                    return
                }
                
                interactor.createTransaction(
                    amount: transactionAmount,
                    date: transactionDate.millisecondsSince1970,
                    note: "BALANCE RECONCILIATION\(note.map({ " - " + $0 }) ?? "")",
                    labels: [],
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

private extension ReconcileBalanceSheet {
    @ViewBuilder
    func buildStateView(_ state: Loadable<Transaction>) -> some View {
        switch state {
        case .loading:
            ProgressView()
        case .error(let error):
            Text("Error: \(error.localizedDescription)")
                .applyErrorTextStyle()
        case .idle:
            EmptyView()
        case .data:
            Text("Reconciliation transaction successfully created")
                .applyInfoTextStyle()
                .task {
                    try? await Task.sleep(for: .seconds(0.75))
                    interactor.loadTransactions()
                    isPresented = false
                }
        }
    }
}

#Preview {
    ReconcileBalanceSheet(isPresented: .constant(true))
        .environmentObject(
            TransactionInteractor(
                chest: ChestRepositoryStub.data.first!,
                repo: TransactionRepositoryStub()
            )
        )
}
