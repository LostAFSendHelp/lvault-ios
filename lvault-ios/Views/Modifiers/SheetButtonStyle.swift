//
//  SheetButtonStyle.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 5/26/24.
//

import Foundation
import SwiftUI

struct SheetButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.frame(maxWidth: .infinity).padding(.vertical, 6)
    }
}

extension View {
    func applySheetButtonStyle() -> some View {
        modifier(SheetButtonStyle())
    }
}
