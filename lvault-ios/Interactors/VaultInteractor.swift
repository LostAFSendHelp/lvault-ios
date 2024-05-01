//
//  VaultInteractor.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import Foundation
import SwiftUI

class VaultInteractor: ObservableObject {
    @Published var vaults: LoadableList<Vault> = .loading
    
    private let repo: VaultRepository
    private var subscriptions: DisposeBag = []
    
    init(repo: VaultRepository) {
        self.repo = repo
    }
    
    func loadVaults() {
        vaults = .loading
        repo.getVaults()
            .sink(
                receiveCompletion: { [weak self] result in
                    guard let self, case .failure(let error) = result else { return }
                    vaults = .error(error)
                },
                receiveValue: { [weak self] data in
                    guard let self else { return }
                    vaults = .data(data.sorted(by: { left, right in left.createdAt < right.createdAt }))
                }
            ).store(in: &subscriptions)
    }
    
    func createVault(named name: String, into binding: Binding<Loadable<Vault>>) {
        repo.createVault(named: name)
            .sink(
                receiveCompletion: { result in
                    guard case .failure(let error) = result else { return }
                    binding.wrappedValue = .error(error)
                },
                receiveValue: { vault in
                    binding.wrappedValue = .data(vault)
                }
            ).store(in: &subscriptions)
    }
}
