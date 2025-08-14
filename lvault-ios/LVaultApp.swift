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
    @StateObject private var loadingManager: LoadingManager = .init()
    @State private var startupLoadable: Loadable<Void> = .loading
    
    var body: some View {
        switch startupLoadable {
        case .loading:
            SplashScreen(
                startupLoadable: $startupLoadable,
                interactor: .init(
                    persistenceController: di.container.persistence,
                    localAuthRepo: di.container.localAuthRepo
                )
            )
        case .data:
            TabView {
                Home()
                    .environmentObject(di.container.getVaultInteractor())
                
                Manage()
                    .environmentObject(di.container.getTransactionLabelInteractor())
                
                Reports()
                    .environmentObject(di.container.getReportInteractor())
                
                Settings()
            }
            .overlay {
                if loadingManager.isLoading {
                    ZStack {
                        Color.black.opacity(0.5)
                        ProgressView().progressViewStyle(.circular)
                    }.ignoresSafeArea()
                }
            }
            .environmentObject(loadingManager)
        case .error(let error):
            if let lvaultError = error as? LVaultError,
               case .authenticationFailure = lvaultError {
                AuthenticationErrorScreen(onRetry: {
                    startupLoadable = .loading
                }).environmentObject(AuthenticationErrorInteractor(repo: di.container.localAuthRepo))
            } else {
                StartupErrorScreen(
                    error: error,
                    onRetry: {
                        startupLoadable = .loading
                    }
                )
            }
        case .idle:
            EmptyView()
        }
    }
}

//#Preview {
//    MainView()
//        .dependency(.preview)
//}
