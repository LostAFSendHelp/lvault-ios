//
//  TransactionLabelRepository.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/25/24.
//

import Foundation
import Combine
import CoreStore

protocol TransactionLabelRepository: AnyObject {
    func getTransactionLabels() -> AnyPublisher<[TransactionLabel], Error>
    func createTransactionLabel(name: String, color: String) -> AnyPublisher<TransactionLabel, Error>
    func deleteTransactionLabel(_ transactionLabel: TransactionLabel) -> AnyPublisher<Void, Error>
}

class TransactionLabelRepositoryImpl: TransactionLabelRepository {
    private let persistence: PersistenceController
    
    init(persistence: PersistenceController) {
        self.persistence = persistence
    }
    
    func getTransactionLabels() -> AnyPublisher<[TransactionLabel], Error> {
        Future { [unowned self] promise in
            do {
                let data: [TransactionLabelCSO] = try persistence.fetchAll()
                promise(.success(data))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func createTransactionLabel(name: String, color: String) -> AnyPublisher<TransactionLabel, Error> {
        Future { [unowned self] promise in
            persistence.create(
                { (cso: TransactionLabelCSO, trsn: AsynchronousDataTransaction) -> Void in
                    cso.name = name
                    cso.color = color
                },
                completion: { result in
                    switch result {
                    case .success(let cso):
                        promise(.success(cso))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            )
        }.eraseToAnyPublisher()
    }
    
    func deleteTransactionLabel(_ transactionLabel: TransactionLabel) -> AnyPublisher<Void, Error> {
        Future { [unowned self] promise in
            guard let tLabel = transactionLabel as? TransactionLabelCSO else {
                promise(.failure(LVaultError.invalidArguments("Expected TransactionLabelCSo")))
                return
            }
            
            persistence.delete(
                tLabel,
                completion: { result in
                    switch result {
                    case .success:
                        promise(.success(()))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            )
        }.eraseToAnyPublisher()
    }
}
