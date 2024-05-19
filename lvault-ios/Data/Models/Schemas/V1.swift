//
//  V1.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/29/24.
//

import Foundation
import CoreStore

typealias VaultCSO = V1.VaultCSO
typealias ChestCSO = V1.ChestCSO
typealias TransactionCSO = V1.TransactionCSO
typealias TransactionLabelCSO = V1.TransactionLabelCSO

enum V1 {
    class VaultCSO: CoreStoreObject {
        @Field.Stored("id", dynamicInitialValue: { UUID().uuidString })
        private(set) var id: String
        
        @Field.Stored("name")
        var name: String = "New vault"
        
        @Field.Relationship("chests")
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
        
        @Field.Relationship("vault", inverse: \.$rChests)
        var rVault: VaultCSO?
        
        @Field.Relationship("transactions")
        var rTransactions: [TransactionCSO]
        
        @Field.Stored("createdAt", dynamicInitialValue: { Date().millisecondsSince1970 })
        private(set) var createdAt: Double
    }
    
    class TransactionCSO: CoreStoreObject {
        @Field.Stored("id", dynamicInitialValue: { UUID().uuidString })
        private(set) var id: String
        
        @Field.Stored("amount")
        var amount: Double = 0
        
        @Field.Stored("transactionDate", dynamicInitialValue: { Date().millisecondsSince1970 })
        var transactionDate: Double
        
        @Field.Stored("note")
        var note: String?
        
        @Field.Relationship("chest", inverse: \.$rTransactions)
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
        modelVersion: "V1",
        entities: [
            Entity<V1.VaultCSO>("Vault"),
            Entity<V1.ChestCSO>("Chest"),
            Entity<V1.TransactionCSO>("Transaction"),
            Entity<V1.TransactionLabelCSO>("TransactionLabel"),
        ]
    )
}
