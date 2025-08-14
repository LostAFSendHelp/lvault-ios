//
//  FullscreenLoading.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/23/25.
//

import SwiftUI

struct FullscreenLoading: ViewModifier {
    var isLoading: Bool = false
    @EnvironmentObject private var loadingManager: LoadingManager
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isLoading) { isLoading in
                if isLoading {
                    loadingManager.showLoading()
                } else {
                    loadingManager.hideLoading()
                }
            }
    }
}

extension View {
    func fullScreenLoading(_ isLoading: Bool) -> some View {
        modifier(FullscreenLoading(isLoading: isLoading))
    }
}
