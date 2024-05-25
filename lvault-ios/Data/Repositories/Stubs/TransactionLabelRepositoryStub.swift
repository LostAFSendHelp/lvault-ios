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
        .init(id: "1", name: "Label 1", color: "#FF6262", createdAt: Date().millisecondsSince1970),
        .init(id: "2", name: "Label 2", color: "#41DD41", createdAt: Date().millisecondsSince1970),
        .init(id: "3", name: "Label 3", color: "#6262FF", createdAt: Date().millisecondsSince1970),
    ]
    
    private var data: [TransactionLabelDTO]
    
    init() {
        self.data = Self.data
    }
    
    func getTransactionLabels() -> AnyPublisher<[TransactionLabel], Error> {
        return Just(data)
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createTransactionLabel(name: String, color: String) -> AnyPublisher<TransactionLabel, Error> {
        let new = TransactionLabelDTO(id: name, name: name, color: color, createdAt: Date().millisecondsSince1970)
        data.append(new)
        return Just(new)
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateTransactionLabel(_ transactionLabel: TransactionLabel, name: String, color: String) -> AnyPublisher<TransactionLabel, Error> {
        guard let tLabel = transactionLabel as? TransactionLabelDTO else {
            return Fail(error: LVaultError.invalidArguments("Expected TransactionLabelDTO"))
                .eraseToAnyPublisher()
        }
        
        guard let index = data.firstIndex(where: { $0.id == tLabel.id }) else {
            return Fail(error: LVaultError.notFound("No corresponding TransactionLabel found"))
                .eraseToAnyPublisher()
        }
        
        let old = data[index]
        data[index] = .init(
            id: old.id,
            name: tLabel.name,
            color: tLabel.color,
            createdAt: old.createdAt
        )
        
        return Just<TransactionLabel>(data[index])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
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
