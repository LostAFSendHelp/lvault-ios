//
//  ChestRepositoryStub.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/22/24.
//

import Foundation
import Combine

class ChestRepositoryStub: ChestRepository {
    static let data: [ChestDTO] = [
        .create(vaultId: "1", name: "example chest 1", initialAmount: 10000, currentAmount: 10001),
        .create(vaultId: "2", name: "example chest 2", initialAmount: 20000, currentAmount: 20002),
        .create(vaultId: "3", name: "example chest 3", initialAmount: 30000, currentAmount: 30003),
        .create(vaultId: "4", name: "example chest 4", initialAmount: 40000, currentAmount: 40004),
    ]
    
    private(set) var data: [ChestDTO]
    
    init() {
        data = Self.data
    }
    
    func getChests(vault: Vault) -> AnyPublisher<[Chest], Error> {
        return Just(data)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createChest(named name: String, initialAmount: Double, vault: Vault) -> AnyPublisher<Chest, Error> {
        let new = ChestDTO.create(vaultId: "1", name: name)
        data.append(new)
        
        return Just(new)
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteChest(_ chest: Chest) -> AnyPublisher<Void, Error> {
        guard let chest = chest as? ChestDTO else {
            return Fail(error: LVaultError.invalidArguments("Expected ChestDTO"))
                .eraseToAnyPublisher()
        }
        
        data.removeAll(where: { $0.id == chest.id })
        return Just<Void>(())
            .delay(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
