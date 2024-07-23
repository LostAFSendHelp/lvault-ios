//
//  StartupErrorScreen.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 7/23/24.
//

import SwiftUI

struct StartupErrorScreen: View {
    let error: Error
    let onRetry: EmptyVoidHandler
    
    var body: some View {
        Text("Error during app startup:")
            .multilineTextAlignment(.center)
        
        Text(error.localizedDescription)
            .foregroundStyle(.red)
            .padding(.bottom, 20)
        
        Button(action: onRetry, label: {
            Text("Retry")
        }).padding(.bottom, 20)
        
        Button(action: { print("report") }, label: {
            Text("Report")
        })
    }
}

#Preview {
    StartupErrorScreen(
        error: LVaultError.custom("Preview error"),
        onRetry: { print("retry") }
    )
}
