//
//  VaultInteractor.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import Foundation
import SwiftUI

protocol VaultInteractor {
    func loadVaults(into binding: Binding<Loadable<[Vault]>>)
}

class VaultInteractorImpl: VaultInteractor {
    private let repo: VaultRepository
    private var subscriptions: DisposeBag = []
    
    init(repo: VaultRepository) {
        self.repo = repo
    }
    
    func loadVaults(into binding: Binding<Loadable<[Vault]>>) {
        repo.getVaults()
            .sink(
                receiveCompletion: { result in
                    guard case .failure(let error) = result else { return }
                    binding.wrappedValue = .error(error)
                },
                receiveValue: { data in
                    let vaults = data.map({ Vault(id: $0.id, name: $0.name) })
                    binding.wrappedValue = .data(vaults)
                }
            ).store(in: &subscriptions)
    }
}
