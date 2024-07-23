//
//  SplashInteractor.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 6/30/24.
//

import Foundation
import Combine

class SplashInteractor {
    private let persistenceController: PersistenceController
    private let localAuthRepo: LocalAuthRepository
    private var subscriptions: DisposeBag = []
    
    init(
        persistenceController: PersistenceController,
        localAuthRepo: LocalAuthRepository
    ) {
        self.persistenceController = persistenceController
        self.localAuthRepo = localAuthRepo
    }
    
    func initializeApp(completion: @escaping ResultHandler<Void>) {
        Publishers
            .CombineLatest3(
                startMinCountDown(),
                initializePersistenceStore(),
                authenticateUser()
            ).sink(
                receiveCompletion: { result in
                    switch result {
                    case .finished: completion(.success(()))
                    case .failure(let error): completion(.failure(error))
                    }
                },
                receiveValue: { _ in }
            ).store(in: &subscriptions)
    }
}

private extension SplashInteractor {
    func startMinCountDown() -> AnyPublisher<Void, Error> {
        return Just<Void>(())
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func initializePersistenceStore() -> AnyPublisher<Void, Error> {
        return Future { [unowned self] promise in
            persistenceController.initialize(completion: { result in
                switch result {
                case .success:
                    promise(.success(()))
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        }.eraseToAnyPublisher()
    }
    
    func authenticateUser() -> AnyPublisher<Void, Error> {
        return localAuthRepo.authenticate()
    }
}
