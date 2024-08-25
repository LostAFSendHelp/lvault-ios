//
//  Transaction+CSO.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/29/24.
//

// conformation for old model V1

extension V1.TransactionCSO {
    var isTransfer: Bool {
        false
    }
}

extension TransactionCSO: Transaction {
    var labels: [TransactionLabel] {
        return Array(rLabels)
    }
    
    var chestName: String {
        return rChest?.name ?? "ERROR"
    }
}
