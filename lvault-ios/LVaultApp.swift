//
//  LVaultApp.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/19/24.
//

import SwiftUI

@main
struct LVaultApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .dependency(.shared)
        }
    }
}

struct MainView: View {
    @EnvironmentObject private var di: DI
    
    var body: some View {
        TabView {
            Home()
                .environmentObject(di.container.getVaultInteractor())
            
            Manage()
                .environmentObject(di.container.getTransactionLabelInteractor())
            
            Settings()
        }
    }
}

#Preview {
    MainView()
        .dependency(.preview)
}
