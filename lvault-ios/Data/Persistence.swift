//
//  Persistence.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/19/24.
//

import CoreStore

class PersistenceController {
    static let shared = PersistenceController(inMemory: false) // TODO: update logic here
    static let preview: PersistenceController = .init(inMemory: true)
    
    let inMemory: Bool
    
    private var store: DataStack {
        CoreStoreDefaults.dataStack
    }
    
    init(inMemory: Bool = false) {
        self.inMemory = inMemory
    }
    
    func initialize(completion: @escaping EmptyVoidHandler) {
        CoreStoreDefaults.dataStack = DataStack(
            V1.schema,
            V2.schema,
            migrationChain: [V1.version, V2.version]
        )
        
        if inMemory {
            do {
                try CoreStoreDefaults.dataStack.addStorageAndWait(InMemoryStore())
                create({ (cso: VaultCSO, _) -> Void in
                    cso.name = "example vault"
                })
                completion()
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            let storage = SQLiteStore()
            _ = CoreStoreDefaults.dataStack.addStorage(storage, completion: { result in
                switch result {
                case .success:
                    completion()
                case .failure(let error):
                    // TODO: gracefully handle errors
                    fatalError(error.localizedDescription)
                }
            })
        }
    }
}

extension PersistenceController {
    func fetchAll<T: CoreStoreObject>(_ format: String? = nil, _ args: Any...) throws -> [T] {
        if let format {
            return try store.fetchAll(
                From<T>(),
                Where<T>(format, args)
            )
        } else {
            return try store.fetchAll(From<T>())
        }
    }
    
    func fetchFirst<T: CoreStoreObject>(_ format: String, _ args: Any...) throws -> T? {
        return try store.fetchOne(
            From<T>(),
            Where<T>(format, args)
        )
    }
    
    func create<T: CoreStoreObject>(
        _ closure: VoidHandler2Throws<T, AsynchronousDataTransaction>? = nil,
        completion: VoidHandler<AsynchronousDataTransaction.Result<T>>? = nil
    ) {
        store.perform(
            asynchronous: { transaction in
                let object = transaction.create(Into<T>())
                try closure?(object, transaction)
                return object
            },
            completion: { result in
                switch result {
                case .success(let cso):
                    let cso = self.store.fetchExisting(cso)!
                    completion?(.success(cso))
                default:
                    completion?(result)
                }
            }
        )
    }
    
    func update<T: CoreStoreObject>(
        object: T,
        updates: VoidHandler2Throws<T, AsynchronousDataTransaction>? = nil,
        completion: VoidHandler<AsynchronousDataTransaction.Result<T>>? = nil
    ) {
        store.perform(
            asynchronous: { transaction in
                let object = transaction.edit(object)!
                try updates?(object, transaction)
                return object
            },
            completion: { result in
                switch result {
                case .success(let cso):
                    let cso = self.store.fetchExisting(cso)!
                    completion?(.success(cso))
                default:
                    completion?(result)
                }
            }
        )
    }
    
    func delete<T: CoreStoreObject>(
        _ object: T,
        willDelete: VoidHandler2Throws<T, AsynchronousDataTransaction>? = nil,
        completion: VoidHandler<AsynchronousDataTransaction.Result<Void>>? = nil
    ) {
        store.perform(
            asynchronous: { transaction in
                let object = transaction.edit(object)!
                try willDelete?(object, transaction)
                transaction.delete(object)
            },
            completion: completion ?? { _ in }
        )
    }
}
