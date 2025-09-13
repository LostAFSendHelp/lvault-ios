//
//  TransactionSuggestion.swift
//  lvault-ios
//
//  Created by Claude on 8/16/25.
//

import Foundation
import UIKit

struct TransactionSuggestionData {
    var image: UIImage
    var suggestions: [TransactionSuggestion]
}

struct TransactionSuggestion {
    var amount: Double
    var timestamp: Double
    var note: String?
    var labelIds: [String]
    var transferTarget: (any Chest)?
}

extension TransactionSuggestion {
    init(from item: ScanDocResultItem) {
        self.amount = item.amount
        self.timestamp = item.timestamp
        self.note = item.note
        self.labelIds = []
    }
}
