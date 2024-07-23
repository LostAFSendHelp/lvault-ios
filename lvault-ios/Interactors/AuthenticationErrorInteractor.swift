//
//  AuthenticationErrorInteractor.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 7/23/24.
//

import Foundation
import LocalAuthentication
import Combine

class AuthenticationErrorInteractor: ObservableObject {
    private let repo: LocalAuthRepository
    
    var biometryType: LABiometryType { repo.biometryType }
    
    var biometryTypeImage: String {
        switch biometryType {
        case .faceID:
            return "faceid"
        case .opticID:
            return "opticid"
        case .touchID:
            return "touchid"
        default:
            return ""
        }
    }
    
    init(repo: LocalAuthRepository) {
        self.repo = repo
    }
    
    func report() {
        // placeholder, will implement later
        print("mine report")
    }
    
    func retry() -> AnyPublisher<Void, Error> {
        return repo.authenticate()
    }
}
