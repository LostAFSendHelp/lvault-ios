//
//  TextView.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 6/3/24.
//

import SwiftUI

struct TextView: View {
    let title: String?
    @Binding var text: String?
    
    private var textBinding: Binding<String> {
        .init(
            get: { text ?? "" },
            set: { newText in text = newText.isEmpty ? nil : newText }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let title {
                Text(title)
                    .font(.system(size: 14))
            }
            
            TextEditor(text: textBinding)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .roundedBorder(cornerRadius: 12, color: .gray.opacity(0.25))
        }
    }
}

#Preview {
    TextView(
        title: "Text view",
        text: .constant(nil)
    )
    .frame(height: 100)
    .padding()
}
