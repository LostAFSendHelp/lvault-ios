//
//  TransactionLabelSheet.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/26/24.
//

import SwiftUI

struct TransactionLabelSheet: View {
    enum Intent {
        case create, edit(TransactionLabel)
    }
    
    var isPresented: Binding<Bool>
    let intent: Intent
    @State private var name: String
    @State private var color: Color
    @State private var transactionLabelLoadable: Loadable<TransactionLabel> = .idle
    @EnvironmentObject private var transactionLabelInteractor: TransactionLabelInteractor
    
    private var isCreatingLabel: Bool {
        switch intent {
        case .create:
            return true
        case .edit:
            return false
        }
    }
    
    private var editingLabel: TransactionLabel? {
        switch intent {
        case .create:
            return nil
        case .edit(let tLabel):
            return tLabel
        }
    }
    
    init(isPresented: Binding<Bool>, intent: Intent) {
        self.isPresented = isPresented
        self.intent = intent
        
        switch intent {
        case .create:
            _name = .init(initialValue: "My brand new label")
            _color = .init(initialValue: .black)
        case .edit(let tLabel):
            _name = .init(initialValue: tLabel.name)
            _color = .init(initialValue: tLabel.color.color)
        }
    }
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: UIConfigs.verticalSpacing
        ) {
            Text(isCreatingLabel ? "Create a new label" : "Edit your label")
                .font(.largeTitle)
                .padding(.bottom, 20)
            Text("Preview:")
            
            buildPreviewLabel()
            
            TextField(
                text: $name,
                prompt: Text("Label name...").italic(),
                label: { Text("") }
            )
            .applyBasicInputStyle()
            
            ColorPicker(selection: $color, label: {
                Text("Pick a color for your label")
            })
            .padding(.bottom, 20)
            
            buildStateView(transactionLabelLoadable)
            
            Button(action: performAction, label: {
                Text(isCreatingLabel ? "Create" : "Update").applySheetButtonStyle()
            }).buttonStyle(.borderedProminent)
            
            Button(action: { isPresented.wrappedValue = false }, label: {
                Text("Cancel").applySheetButtonStyle()
            }).buttonStyle(.bordered)
        }.padding()
    }
}

private extension TransactionLabelSheet {
    @ViewBuilder
    func buildPreviewLabel() -> some View {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            Text("Enter a label name to see a preview of the label").italic()
        } else {
            LabelView(text: name, color: color)
        }
    }
    
    @ViewBuilder
    func buildStateView(_ state: Loadable<TransactionLabel>) -> some View {
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
            Text("Transaction label successfully \(isCreatingLabel ? "created" : "updated")").task {
                try? await Task.sleep(for: .seconds(0.75))
                transactionLabelInteractor.loadTransactionLabels()
                isPresented.wrappedValue = false
            }
        }
    }
    
    func performAction() {
        if let editingLabel {
            transactionLabelInteractor.updateTransactionLabel(
                editingLabel,
                name: name,
                color: color.hexString,
                into: $transactionLabelLoadable
            )
        } else {
            transactionLabelInteractor.createTransactionLabel(
                name: name,
                color: color.hexString,
                into: $transactionLabelLoadable
            )
        }
    }
}

#Preview {
    TransactionLabelSheet(
        isPresented: .constant(true),
        intent: .create
    ).environmentObject(DI.preview.container.getTransactionLabelInteractor())
}
