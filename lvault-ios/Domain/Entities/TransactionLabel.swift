//
//  TransactionLabel.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/29/24.
//

import UIKit

protocol TransactionLabel {
    var id: String { get }
    var name: String { get }
    var color: String { get }
    var createdAt: Double { get }
}

extension TransactionLabel {
    var identifier: String {
        return id + name + color
    }
}

struct TransactionLabelDTO: TransactionLabel {
    let id: String
    let name: String
    let color: String
    let createdAt: Double
}
