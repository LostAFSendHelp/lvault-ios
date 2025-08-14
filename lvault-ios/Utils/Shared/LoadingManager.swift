//
//  LoadingManager.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/23/25.
//

import SwiftUI

@MainActor
class LoadingManager: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    
    func showLoading() {
        isLoading = true
    }
    
    func hideLoading() {
        isLoading = false
    }
}
