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
    
    func transfer(
        from: Chest,
        to: Chest,
        amount: Double,
        at: Double,
        note: String?
    ) -> AnyPublisher<Void, Error> {
        Future { [unowned self] promise in
            guard let from = from as? ChestDTO,
                  let to = to as? ChestDTO
            else {
                promise(.failure(LVaultError.invalidArguments("Expected ChestDTO")))
                return
            }
            
            guard from.id != to.id else {
                promise(.failure(LVaultError.invalidArguments("Cannot transfer to the same chest")))
                return
            }
            
            guard amount > 0 else {
                promise(.failure(LVaultError.invalidArguments("Invalid transfer amount")))
                return
            }
            
            guard let fromIndex = data.firstIndex(where: { $0.id == from.id }),
                  let toIndex = data.firstIndex(where: { $0.id == to.id })
            else {
                promise(.failure(LVaultError.notFound("Chest(s) not found")))
                return
            }
            
            let now = Date()
            
            var _from = data[fromIndex]
            let send = TransactionDTO(
                id: "\(now)",
                amount: -amount,
                isTransfer: true,
                transactionDate: at,
                note: "To [\(to.name)] (\(note ?? "NULL"))",
                labels: [],
                createdAt: now.millisecondsSince1970
            )
            _from.transactions.append(send)
            _from.currentAmount -= amount
            data[fromIndex] = _from
            
            var _to = data[toIndex]
            let receive = TransactionDTO(
                id: "\(now)",
                amount: amount,
                isTransfer: true,
                transactionDate: at,
                note: "From [\(from.name)] (\(note ?? "NULL"))",
                labels: [],
                createdAt: now.millisecondsSince1970
            )
            _to.transactions.append(receive)
            _to.currentAmount += amount
            data[toIndex] = _to
            
            Task {
                try await Task.sleep(for: .seconds(1))
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
}
