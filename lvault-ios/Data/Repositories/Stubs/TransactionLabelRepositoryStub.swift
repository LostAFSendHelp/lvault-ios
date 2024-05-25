//
//  TransactionLabelRepositoryStub.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/25/24.
//

import Foundation
import Combine

class TransactionLabelRepositoryStub: TransactionLabelRepository {
    static let data: [TransactionLabelDTO] = [
        .init(id: "1", name: "Label 1", color: "#552121", createdAt: Date().millisecondsSince1970),
        .init(id: "2", name: "Label 2", color: "#215521", createdAt: Date().millisecondsSince1970),
        .init(id: "3", name: "Label 3", color: "#215521", createdAt: Date().millisecondsSince1970),
    ]
    
    private var data: [TransactionLabelDTO]
    
    init() {
        self.data = Self.data
    }
    
    func getTransactionLabels() -> AnyPublisher<[TransactionLabel], Error> {
        return Just(data).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func createTransactionLabel(name: String, color: String) -> AnyPublisher<TransactionLabel, Error> {
        let new = TransactionLabelDTO(id: name, name: name, color: color, createdAt: Date().millisecondsSince1970)
        data.append(new)
        return Just(new).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func deleteTransactionLabel(_ transactionLabel: TransactionLabel) -> AnyPublisher<Void, Error> {
        guard let tLabel = transactionLabel as? TransactionLabelDTO else {
            return Fail(error: LVaultError.invalidArguments("Expected TransactionLabelDTO"))
                .eraseToAnyPublisher()
        }
        
        data.removeAll(where: { $0.id == tLabel.id })
        return Just<Void>(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
