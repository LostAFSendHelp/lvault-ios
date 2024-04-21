//
//  VaultRepository.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import Foundation
import Combine

protocol VaultRepository {
    func getVaults() -> AnyPublisher<[VaultEntity], Error>
}

struct VaultRepositoryStub: VaultRepository {
    static var data: [VaultEntity] {
        return [
            .init(id: "id1", name: "vault 1"),
            .init(id: "id2", name: "vault 2"),
            .init(id: "id3", name: "vault 3"),
            .init(id: "id4", name: "vault 4"),
            .init(id: "id5", name: "vault 5"),
        ]
    }
    
    func getVaults() -> AnyPublisher<[VaultEntity], Error> {
        return Just(Self.data)
            .delay(for: 2, scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
