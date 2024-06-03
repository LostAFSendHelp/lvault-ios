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
    @State private var note: String?
    @State private var selectedLabels: [TransactionLabel] = []
    @State private var showTransactionLabelsSheet: Bool = false
    @EnvironmentObject private var interactor: TransactionInteractor
    @EnvironmentObject private var di: DI
    
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
            
            HStack {
                Button(action: { showTransactionLabelsSheet = true }) {
                    Text("Select labels")
                }.fixedSize()
                
                Spacer(minLength: 16)
                
                if !selectedLabels.isEmpty {
                    ScrollView(.horizontal) {
                        LazyHStack(alignment: .center) {
                            ForEach(selectedLabels, id: \.id) { label in
                                LabelView(text: label.name, color: label.color.color)
                            }
                        }.frame(maxHeight: 40)
                    }.scrollIndicators(.never)
                }
            }
            
            TextView(title: "Add a note", text: $note)
                .frame(height: 120)
                .padding(.bottom)
            
            buildStateView(transactionLoadable)
            
            Button(action: {
                guard let amount else {
                    transactionLoadable = .error(LVaultError.custom("Transaction amount missing"))
                    return
                }
                
                interactor.createTransaction(
                    amount: amount * (isExpense ? -1 : 1),
                    date: date.millisecondsSince1970,
                    note: note,
                    labels: selectedLabels,
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
        }
        .padding()
        .sheet(isPresented: $showTransactionLabelsSheet) {
            SelectTransactionLabelsSheet(
                isPresented: $showTransactionLabelsSheet,
                selectedLabels: selectedLabels,
                onConfirm: { labels in
                    selectedLabels = labels
                    showTransactionLabelsSheet = false
                }
            ).environmentObject(di.container.getTransactionLabelInteractor())
        }
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
        .environmentObject(DI.preview)
        .environmentObject(
            TransactionInteractor(
                chest: ChestRepositoryStub.data.first!,
                repo: TransactionRepositoryStub()
            )
        )
}
