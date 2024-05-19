//
//  Chest+CSO.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/29/24.
//

extension ChestCSO: Chest {
    var transactions: [Transaction] {
        return rTransactions
    }
}
