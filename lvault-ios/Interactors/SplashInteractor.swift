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
    private var subscriptions: DisposeBag = []
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
    
    func initializeApp(completion: @escaping EmptyVoidHandler) {
        Publishers
            .CombineLatest(
                startMinCountDown(),
                initializePersistenceStore()
            ).sink(receiveValue: { _ in
                completion()
            }).store(in: &subscriptions)
    }
}

private extension SplashInteractor {
    func startMinCountDown() -> VoidPublisher {
        return Just<Void>(())
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func initializePersistenceStore() -> VoidPublisher {
        return Future { [unowned self] promise in
            persistenceController.initialize(completion: { promise(.success(())) })
        }.eraseToAnyPublisher()
    }
}
