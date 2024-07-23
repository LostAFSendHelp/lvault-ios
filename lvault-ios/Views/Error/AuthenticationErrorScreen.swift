//
//  AuthenticationErrorScreen.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 7/23/24.
//

import SwiftUI

struct AuthenticationErrorScreen: View {
    let onRetry: EmptyVoidHandler
    @EnvironmentObject private var interactor: AuthenticationErrorInteractor
    
    var body: some View {
        Text("Failed to authenticate user")
            .multilineTextAlignment(.center)
            .padding(.bottom, 20)
        
        Button(action: onRetry, label: {
            Text("Retry")
            Image(systemName: interactor.biometryTypeImage) // depends on biometry type
        })
    }
}

#Preview {
    AuthenticationErrorScreen(onRetry: { print("retry") })
        .environmentObject(AuthenticationErrorInteractor(repo: LocalAuthRepositoryStub(fails: false)))
}
