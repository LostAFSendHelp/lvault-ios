//
//  V2.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 6/25/24.
//

import Foundation
import CoreStore

/// Update: add TransactionCSO.isTransfer
enum V2 {
    static var version: String = "V2"
    
    class VaultCSO: CoreStoreObject {
        @Field.Stored("id", dynamicInitialValue: { UUID().uuidString })
        private(set) var id: String
        
        @Field.Stored("name")
        var name: String = "New vault"
        
        @Field.Relationship("chests", deleteRule: .cascade)
        var rChests: [ChestCSO]
        
        @Field.Stored("createdAt", dynamicInitialValue: { Date().millisecondsSince1970 })
        private(set) var createdAt: Double
    }
    
    class ChestCSO: CoreStoreObject {
        @Field.Stored("id", dynamicInitialValue: { UUID().uuidString })
        private(set) var id: String
        
        @Field.Stored("name")
        var name: String = "New chest"
        
        @Field.Stored("initialAmount")
        var initialAmount: Double = 0
        
        @Field.Stored("currentAmount")
        var currentAmount: Double = 0
        
        @Field.Relationship("vault", inverse: \.$rChests, deleteRule: .nullify)
        var rVault: VaultCSO?
        
        @Field.Relationship("transactions", deleteRule: .cascade)
        var rTransactions: [TransactionCSO]
        
        @Field.Stored("createdAt", dynamicInitialValue: { Date().millisecondsSince1970 })
        private(set) var createdAt: Double
    }
    
    class TransactionCSO: CoreStoreObject {
        @Field.Stored("id", dynamicInitialValue: { UUID().uuidString })
        private(set) var id: String
        
        @Field.Stored("amount")
        var amount: Double = 0
        
        // new
        @Field.Stored("isTransfer")
        var isTransfer: Bool = false
        
        @Field.Stored("transactionDate", dynamicInitialValue: { Date().millisecondsSince1970 })
        var transactionDate: Double
        
        @Field.Stored("note")
        var note: String?
        
        @Field.Relationship("chest", inverse: \.$rTransactions, deleteRule: .nullify)
        var rChest: ChestCSO?
        
        @Field.Relationship("labels")
        var rLabels: Set<TransactionLabelCSO>
        
        @Field.Stored("createdAt", dynamicInitialValue: { Date().millisecondsSince1970 })
        private(set) var createdAt: Double
    }
    
    class TransactionLabelCSO: CoreStoreObject {
        @Field.Stored("id", dynamicInitialValue: { UUID().uuidString })
        private(set) var id: String
        
        @Field.Stored("name")
        var name: String = "label"
        
        @Field.Stored("color")
        var color: String = "#FFFFFF"
        
        @Field.Relationship("transactions", inverse: \.$rLabels)
        var rTransactions: [TransactionCSO]
        
        @Field.Stored("createdAt", dynamicInitialValue: { Date().millisecondsSince1970 })
        private(set) var createdAt: Double
    }
    
    static var schema: CoreStoreSchema = .init(
        modelVersion: version,
        entities: [
            Entity<V2.VaultCSO>("Vault"),
            Entity<V2.ChestCSO>("Chest"),
            Entity<V2.TransactionCSO>("Transaction"),
            Entity<V2.TransactionLabelCSO>("TransactionLabel"),
        ]
    )
}
