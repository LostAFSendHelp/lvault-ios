//
//  lvault_iosApp.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/19/24.
//

import SwiftUI

@main
struct lvault_iosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Home()
                .environment(\.vaultInteractor, VaultInteractorImpl(repo: VaultRepositoryStub()))
        }
    }
}
