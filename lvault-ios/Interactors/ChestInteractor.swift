//
//  ChestInteractor.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/3/24.
//

import Foundation
import SwiftUI

class ChestInteractor: ObservableObject {
    @Published var chests: LoadableList<Chest> = .loading
    
    private let vault: Vault
    private let repo: ChestRepository
    private var subscriptions: DisposeBag = []
    
    var parentVaultName: String { vault.name }
    
    init(vault: Vault, repo: ChestRepository) {
        self.vault = vault
        self.repo = repo
    }
    
    func loadChests() {
        chests = .loading
        repo.getChests(vaultId: vault.id)
            .sink(
                receiveCompletion: { [weak self] result in
                    guard let self, case .failure(let error) = result else { return }
                    chests = .error(error)
                },
                receiveValue: { [weak self] data in
                    guard let self else { return }
                    chests = .data(data.sorted(by: { left, right in left.createdAt < right.createdAt }))
                }
            ).store(in: &subscriptions)
    }
    
    func createChest(named name: String, initialAmount: Double, into binding: Binding<Loadable<Chest>>) {
        repo.createChest(named: name, initialAmount: initialAmount, vaultId: vault.id)
            .sink(
                receiveCompletion: { result in
                    guard case .failure(let error) = result else { return }
                    binding.wrappedValue = .error(error)
                },
                receiveValue: { chest in
                    binding.wrappedValue = .data(chest)
                }
            ).store(in: &subscriptions)
    }
}
