//
//  Persistence.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/19/24.
//

import CoreStore

class PersistenceController {
    static let shared = PersistenceController(inMemory: true) // TODO: update logic here

    static var preview: PersistenceController = {
        return .init(inMemory: true)
    }()

    private var store: DataStack {
        CoreStoreDefaults.dataStack
    }
    
    init(inMemory: Bool = false) {
        CoreStoreDefaults.dataStack = DataStack(V1.schema)
        
        do {
            if inMemory {
                try CoreStoreDefaults.dataStack.addStorageAndWait(InMemoryStore())
                create({ (cso: VaultCSO) -> Void in
                    cso.name = "example vault"
                })
            } else {
                try CoreStoreDefaults.dataStack.addStorageAndWait(SQLiteStore())
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

extension PersistenceController {
    func fetchAll<T: CoreStoreObject>() throws -> [T] {
        return try store.fetchAll(From<T>())
    }
    
    func create<T: CoreStoreObject>(
        _ closure: VoidHandler<T>? = nil,
        completion: VoidHandler<AsynchronousDataTransaction.Result<T>>? = nil
    ) {
        store.perform(
            asynchronous: { transaction in
                let object = transaction.create(Into<T>())
                closure?(object)
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
}
