//
//  EnvironmentKeys.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import Foundation
import SwiftUI

struct VaultInteractorKey: EnvironmentKey {
    static var defaultValue: VaultInteractor = VaultInteractorImpl(repo: VaultRepositoryStub())
}

extension EnvironmentValues {
    var vaultInteractor: VaultInteractor {
        get { self[VaultInteractorKey.self] }
        set { self[VaultInteractorKey.self] = newValue }
    }
}
