//
//  TransactionSuggestionSheet.swift
//  lvault-ios
//
//  Created by Claude on 8/16/25.
//

import SwiftUI

struct TransactionSuggestionSheet: View {
    @Binding var isPresented: Bool
    @State private var suggestions: [TransactionSuggestion]
    let transferrableChests: [Chest]
    let onConfirm: VoidHandler<[TransactionSuggestion]>
    let onDismiss: EmptyVoidHandler
    
    init(
        isPresented: Binding<Bool>,
        suggestions: [TransactionSuggestion],
        transferrableChests: [Chest] = [],
        onConfirm: @escaping VoidHandler<[TransactionSuggestion]>,
        onDismiss: @escaping EmptyVoidHandler
    ) {
        self._isPresented = isPresented
        self._suggestions = State(initialValue: suggestions)
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
        self.transferrableChests = transferrableChests
    }
    
    var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("OCR Transaction Suggestions")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 8)
                
                Text("The following transactions were detected from the scanned document:")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
                if suggestions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        
                        Text("No transactions found")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        
                        Text("The OCR scan didn't detect any transaction data in the document.")
                            .font(.body)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(suggestions.indices, id: \.self) { index in
                            TransactionSuggestionRow(
                                suggestion: $suggestions[index],
                                chests: transferrableChests
                            )
                            .listRowInsets(.init(
                                top: 12,
                                leading: 8,
                                bottom: 12,
                                trailing: 8
                            ))
                        }
                        .onDelete(perform: { indexes in
                            guard indexes.count == 1 else { return }
                            
                            suggestions.remove(at: 0)
                        })
                    }
                    .listStyle(.plain)
                }
                
                Spacer()
                
                Button(action: { onConfirm(suggestions) }) {
                    Text("Confirm").applySheetButtonStyle()
                }.buttonStyle(.borderedProminent)
                Button(action: { isPresented = false }) {
                    Text("Cancel").applySheetButtonStyle()
                }.buttonStyle(.bordered)
            }
            .padding()
    }
}

#Preview {
    TransactionSuggestionSheet(
        isPresented: .constant(true),
        suggestions: [
            TransactionSuggestion(
                amount: -25.99,
                timestamp: Date().timeIntervalSince1970 * 1000,
                note: "Coffee purchase",
                labelIds: ["food", "drinks"]
            ),
            TransactionSuggestion(
                amount: -12.50,
                timestamp: Date().addingTimeInterval(-3600).timeIntervalSince1970 * 1000,
                note: "Lunch at restaurant",
                labelIds: ["food"]
            ),
            TransactionSuggestion(
                amount: 1200.00,
                timestamp: Date().addingTimeInterval(-7200).timeIntervalSince1970 * 1000,
                note: nil,
                labelIds: []
            )
        ],
        transferrableChests: ChestRepositoryStub.data,
        onConfirm: { suggestions in
            print("confirmed: \(suggestions.count)")
        },
        onDismiss: { }
    )
}

#Preview("Empty State") {
    TransactionSuggestionSheet(
        isPresented: .constant(true),
        suggestions: [],
        onConfirm: { suggestions in print("confirmed: \(suggestions.count)") },
        onDismiss: { }
    )
}
