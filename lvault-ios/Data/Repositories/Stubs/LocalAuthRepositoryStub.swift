//
//  LocalAuthRepositoryStub.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 7/23/24.
//

import Foundation
import Combine
import LocalAuthentication

class LocalAuthRepositoryStub: ObservableObject, LocalAuthRepository {
    var biometryType: LABiometryType { .touchID }
    private let fails: Bool
    
    init(fails: Bool) {
        self.fails = fails
    }
    
    func authenticate() -> AnyPublisher<Void, Error> {
        if fails {
            return Fail(error: LVaultError.authenticationFailure)
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        } else {
            return Just<Void>(())
                .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}
