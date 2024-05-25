//
//  BasicInputStyle.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/26/24.
//

import Foundation
import SwiftUI

struct BasicInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.multilineTextAlignment(.center)
            .lineLimit(1)
            .textFieldStyle(.roundedBorder)
    }
}

extension View {
    func applyBasicInputStyle() -> some View {
        modifier(BasicInputStyle())
    }
}
