//
//  LVaultApp.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/19/24.
//

import SwiftUI

@main
struct LVaultApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .dependency(.shared)
        }
    }
}

struct MainView: View {
    @EnvironmentObject private var di: DI
    @State private var isAppInitialized = false
    
    var body: some View {
        if isAppInitialized {
            TabView {
                Home()
                    .environmentObject(di.container.getVaultInteractor())
                
                Manage()
                    .environmentObject(di.container.getTransactionLabelInteractor())
                
                Settings()
            }
        } else {
            SplashScreen(
                isAppInitialized: $isAppInitialized,
                interactor: .init(persistenceController: di.container.persistence)
            )
        }
    }
}

#Preview {
    MainView()
        .dependency(.preview)
}
