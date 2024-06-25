//
//  DIContainer.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/23/24.
//

import Foundation

class DI: ObservableObject {
    let container: any DIContainer
    
    static let shared: DI = .init(container: DIContainerImpl())
    
    static let preview: DI = .init(container: DIContainerPreview())
    
    private init(container: any DIContainer) {
        self.container = container
    }
}

protocol DIContainer: AnyObject {
    var persistence: PersistenceController { get }
    func getVaultInteractor() -> VaultInteractor
    func getChestInteractor(parentVault: Vault) -> ChestInteractor
    func getTransactionInteractor(parentChest: Chest) -> TransactionInteractor
    func getTransactionLabelInteractor() -> TransactionLabelInteractor
}

class DIContainerImpl: DIContainer {
    let persistence: PersistenceController = .shared
    private lazy var vaultInteractor: VaultInteractor = .init(repo: VaultRepositoryImpl(persistence: persistence))
    private lazy var transactionLabelInteractor: TransactionLabelInteractor = .init(repo: TransactionLabelRepositoryImpl(persistence: persistence))
    
    func getVaultInteractor() -> VaultInteractor {
        return vaultInteractor
    }
    
    func getChestInteractor(parentVault: Vault) -> ChestInteractor {
        assert(parentVault is VaultCSO, "Run-time object must be a CSO instance")
        return ChestInteractor(vault: parentVault, repo: ChestRepositoryImpl(persistence: persistence))
    }
    
    func getTransactionInteractor(parentChest: Chest) -> TransactionInteractor {
        assert(parentChest is ChestCSO, "Run-time object must be a CSO instance")
        return TransactionInteractor(chest: parentChest, repo: TransactionRepositoryImpl(persistence: persistence))
    }
    
    func getTransactionLabelInteractor() -> TransactionLabelInteractor {
        return transactionLabelInteractor
    }
}

class DIContainerPreview: DIContainer {
    let persistence: PersistenceController = .preview
    private let vaultInteractor: VaultInteractor = .init(repo: VaultRepositoryStub())
    private let transactionLabelInteractor: TransactionLabelInteractor = .init(repo: TransactionLabelRepositoryStub())
    
    func getVaultInteractor() -> VaultInteractor {
        return vaultInteractor
    }
    
    func getChestInteractor(parentVault: Vault) -> ChestInteractor {
        return ChestInteractor(vault: parentVault, repo: ChestRepositoryStub())
    }
    
    func getTransactionInteractor(parentChest: Chest) -> TransactionInteractor {
        return TransactionInteractor(chest: parentChest, repo: TransactionRepositoryStub())
    }
    
    func getTransactionLabelInteractor() -> TransactionLabelInteractor {
        return transactionLabelInteractor
    }
}
