//
//  LocalAuthRepository.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 7/23/24.
//

import Foundation
import Combine
import LocalAuthentication

protocol LocalAuthRepository {
    var biometryType: LABiometryType { get }
    
    func authenticate() -> AnyPublisher<Void, Error>
}

class LocalAuthRepositoryImpl: LocalAuthRepository {
    static let shared: LocalAuthRepositoryImpl = .init(
        authenticationReason: "To enable you to access your secured vault data",
        allowPasscodeFallback: true
    )
    
    var biometryType: LABiometryType {
        return authContext.biometryType
    }
    
    private let authContext: LAContext
    private let authenticationReason: String
    private let authOption: LAPolicy
    
    init(authContext: LAContext = .init(), authenticationReason: String, allowPasscodeFallback: Bool) {
        self.authContext = authContext
        self.authenticationReason = authenticationReason
        self.authOption = allowPasscodeFallback ? LAPolicy.deviceOwnerAuthentication : .deviceOwnerAuthenticationWithBiometrics
    }
    
    func authenticate() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [unowned self] promise in
            Task {
                var error: NSError?
                
                guard authContext.canEvaluatePolicy(authOption, error: &error) else {
                    return promise(.failure(LVaultError.custom("Error while evaluating authentication policy: \(error?.localizedDescription ?? "UNKNOWN")")))
                }
                
                do {
                    let result = try await authContext.evaluatePolicy(
                        authOption,
                        localizedReason: authenticationReason
                    )
                    
                    if result {
                        promise(.success(()))
                    } else {
                        // will not reach here: exception is thrown when the authentication fails and result is `false`
                        // so the catch block will get called before and there will be no returned result
                        // NOTE: evaluatePolicy will not return until the user or the device for some reason cancels the
                        // process; wrong pass code or unrecognized face will simply repeat the authentication attempt
                        promise(.failure(LVaultError.custom("Unexpected error while authenticating User")))
                    }
                } catch {
                    // will throw error when user cancels the process
                    promise(.failure(LVaultError.authenticationFailure))
                }
            }
        }.eraseToAnyPublisher()
    }
}
