//
//  TextStyles.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 7/1/24.
//

import Foundation
import SwiftUI

struct ErrorTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.red)
            .multilineTextAlignment(.center)
            .font(.system(size: 12))
    }
}

struct InfoTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .font(.system(size: 12))
    }
}

extension View {
    func applyErrorTextStyle() -> some View {
        modifier(ErrorTextStyle())
    }
    
    func applyInfoTextStyle() -> some View {
        modifier(InfoTextStyle())
    }
}
