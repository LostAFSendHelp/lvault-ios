//
//  Transaction+CSO.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/29/24.
//

extension TransactionCSO: Transaction {
    var labels: [TransactionLabel] {
        return Array(rLabels)
    }
}
