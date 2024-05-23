//
//  Dependency.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/23/24.
//

import Foundation
import SwiftUI

struct Dependency: ViewModifier {
    let di: DI
    
    func body(content: Content) -> some View {
        content.environmentObject(di)
    }
}

extension View {
    func dependency(_ di: DI) -> some View {
        modifier(Dependency(di: di))
    }
}
