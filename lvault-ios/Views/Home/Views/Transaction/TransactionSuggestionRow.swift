//
//  TransactionSuggestionRow.swift
//  lvault-ios
//
//  Created by Claude on 8/16/25.
//

import SwiftUI

struct TransactionSuggestionRow: View {
    @Binding var suggestion: TransactionSuggestion
    @State private var isExpense: Bool
    @State private var amountString: String
    @State private var date: Date
    @State private var note: String
    private let chests: [Chest]
    
    private var transferTarget: Binding<String?> {
        .init(
            get: { suggestion.transferTarget?.id },
            set: { value in
                guard let value else {
                    suggestion.transferTarget = nil
                    return
                }
                
                suggestion.transferTarget = chests.first(where: \.id, equals: value)
            }
        )
    }
    
    init(suggestion: Binding<TransactionSuggestion>, chests: [Chest] = []) {
        self._suggestion = suggestion
        self._isExpense = State(initialValue: suggestion.wrappedValue.amount < 0)
        self._amountString = State(initialValue: abs(suggestion.wrappedValue.amount).decimalText)
        self._date = State(initialValue: Date(timeIntervalSince1970: suggestion.wrappedValue.timestamp / 1000))
        self._note = State(initialValue: suggestion.wrappedValue.note ?? "")
        self.chests = chests
    }
    
    private var displayAmount: Double {
        let value = Double(amountString) ?? 0
        return isExpense ? -abs(value) : abs(value)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Amount input with expense toggle
            VStack(alignment: .trailing, spacing: 8) {
                HStack {
                    Text("Amount")
                    Spacer()
                    Text(isExpense ? "-" : "+")
                        .foregroundStyle(isExpense ? .red : .green)
                        .font(.system(size: 18, weight: .semibold))
                    TextField("Amount", text: $amountString)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .foregroundStyle(isExpense ? .red : .green)
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 140)
                        .onChange(of: amountString) { newValue in
                            suggestion.amount = displayAmount
                        }
                }
                
                HStack {
                    if !chests.isEmpty {
                        Text(isExpense ? "Transfer TO" : "Transferred FROM").font(.caption)
                        
                        Menu {
                            Picker("", selection: transferTarget) {
                                Text("None").tag(nil as String?)
                                ForEach(chests, id: \.id) { chest in
                                    Text(chest.name).tag(Optional(chest.id))
                                }
                            }
                        } label: {
                            Text(suggestion.transferTarget?.name ?? "None")
                                .font(.caption)
                        }
                    
                        Spacer()
                    }
                    
                    Button(action: {
                        isExpense.toggle()
                        suggestion.amount = displayAmount
                    }) {
                        HStack(spacing: 4) {
                            Text("Is expense")
                                .font(.caption)
                            Image(systemName: isExpense ? "checkmark.square.fill" : "square")
                        }
                        .foregroundStyle(isExpense ? .red : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            DatePicker("Date & time", selection: $date)
                .font(.system(size: 14))
                .onChange(of: date) { newDate in
                    suggestion.timestamp = newDate.timeIntervalSince1970 * 1000
                }
            
            // Note editor
            HStack {
                Text("Note:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Add note...", text: $note)
                    .textFieldStyle(.automatic)
                    .font(.caption)
                    .onChange(of: note) { newNote in
                        suggestion.note = newNote.isEmpty ? nil : newNote
                    }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let suggestion1 = TransactionSuggestion(
        amount: -25.99,
        timestamp: Date().timeIntervalSince1970 * 1000,
        note: "Coffee purchase from local cafe",
        labelIds: ["food", "drinks"]
    )
    
    let suggestion2 = TransactionSuggestion(
        amount: 1200.00,
        timestamp: Date().addingTimeInterval(-3600).timeIntervalSince1970 * 1000,
        note: nil,
        labelIds: []
    )
    
    let chests = ChestRepositoryStub.data
    
    return List {
        TransactionSuggestionRow(suggestion: .constant(suggestion1), chests: chests)
        TransactionSuggestionRow(suggestion: .constant(suggestion2), chests: chests)
    }
}
