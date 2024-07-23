//
//  SplashScreen.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 6/30/24.
//

import SwiftUI

struct SplashScreen: View {
    @Binding var startupLoadable: Loadable<Void>
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
            interactor.initializeApp { result in
                withAnimation {
                    switch result {
                    case .success:
                        startupLoadable = .data(())
                    case .failure(let error):
                        startupLoadable = .error(error)
                    }
                }
            }
        })
    }
}

#Preview {
    SplashScreen(
        startupLoadable: .constant(.data(())),
        interactor: SplashInteractor(
            persistenceController: .preview,
            localAuthRepo: LocalAuthRepositoryStub(fails: false)
        )
    )
}
