//
//  EditNoteSheet.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 6/3/24.
//

import SwiftUI

struct EditNoteSheet: View {
    @Binding var isPresented: Bool
    @State private var note: String?
    let onConfirm: VoidHandler<String?>
    
    init(
        isPresented: Binding<Bool>,
        note: String? = nil,
        onConfirm: @escaping VoidHandler<String?>
    ) {
        self._isPresented = isPresented
        self.note = note
        self.onConfirm = onConfirm
    }
    
    var body: some View {
        VStack {
            Text("Edit your note")
                .font(.largeTitle.bold())
                .padding(.bottom, 20)
            
            TextView(title: "Note", text: $note)
                .frame(height: 120)
                .padding(.bottom, 24)
            
            Button(action: { onConfirm(note) }) {
                Text("Confirm").applySheetButtonStyle()
            }.buttonStyle(.borderedProminent)
            Button(action: { isPresented = false }) {
                Text("Cancel").applySheetButtonStyle()
            }.buttonStyle(.bordered)
        }.padding()
    }
}

#Preview {
    EditNoteSheet(isPresented: .constant(true), note: "My current note", onConfirm: { _ in })
}
