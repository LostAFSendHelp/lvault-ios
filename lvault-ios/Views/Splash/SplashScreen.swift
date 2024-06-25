//
//  SplashScreen.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 6/30/24.
//

import SwiftUI

struct SplashScreen: View {
    @Binding var isAppInitialized: Bool
    let interactor: SplashInteractor
    
    var body: some View {
        VStack {
            Image(.icChestLarge)
                .resizable()
                .frame(maxWidth: 100, maxHeight: 100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            Spacer()
                .frame(height: 20)
            Text("Vault")
                .font(.largeTitle.bold())
            Text("Finance tracking made simple")
                .italic()
                .foregroundStyle(.secondary)
        }.onAppear(perform: {
            interactor.initializeApp {
                withAnimation {
                    isAppInitialized = true
                }
            }
        })
    }
}

#Preview {
    SplashScreen(
        isAppInitialized: .constant(false),
        interactor: SplashInteractor(persistenceController: .preview)
    )
}
