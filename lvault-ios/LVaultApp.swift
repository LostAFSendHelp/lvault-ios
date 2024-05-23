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
        }
    }
}

struct MainView: View {
    var body: some View {
        TabView {
            Home()
                .environmentObject(VaultInteractor(repo: VaultRepositoryImpl(persistence: .shared)))
            
            Manage()
            
            Settings()
        }
    }
}

#Preview {
    MainView()
}
