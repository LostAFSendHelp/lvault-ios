//
//  V1.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/29/24.
//

import Foundation
import CoreStore

// update the following to newest version when models change
typealias VaultCSO = V1.VaultCSO
typealias ChestCSO = V1.ChestCSO
typealias TransactionCSO = V1.TransactionCSO
typealias TransactionLabelCSO = V1.TransactionLabelCSO

enum V1 {
    class VaultCSO: CoreStoreObject {
        @Field.Stored("id", dynamicInitialValue: { UUID().uuidString })
        var id: String
        
        @Field.Stored("name")
        var name: String = "New vault"
        
        @Field.Relationship("chests")
        var chests: [ChestCSO]
    }
    
    class ChestCSO: CoreStoreObject {
        @Field.Stored("id", dynamicInitialValue: { UUID().uuidString })
        var id: String
        
        @Field.Stored("name")
        var name: String = "New chest"
        
        @Field.Stored("initialAmount")
        var initialAmount: Double = 0
        
        @Field.Relationship("vault", inverse: \.$chests)
        var vault: VaultCSO?
        
        @Field.Relationship("transactions")
        var transactions: [TransactionCSO]
    }
    
    class TransactionCSO: CoreStoreObject {
        @Field.Stored("id", dynamicInitialValue: { UUID().uuidString })
        var id: String
        
        @Field.Stored("amount")
        var amount: Double = 0
        
        @Field.Relationship("chest", inverse: \.$transactions)
        var chest: ChestCSO?
        
        @Field.Relationship("labels")
        var labels: Set<TransactionLabelCSO>
    }
    
    class TransactionLabelCSO: CoreStoreObject {
        @Field.Stored("id", dynamicInitialValue: { UUID().uuidString })
        var id: String
        
        @Field.Stored("name")
        var name: String = "label"
        
        @Field.Stored("color")
        var color: String = "#FFFFFF"
        
        @Field.Relationship("transactions", inverse: \.$labels)
        var transactions: [TransactionCSO]
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
