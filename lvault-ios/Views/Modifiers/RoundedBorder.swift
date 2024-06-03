//
//  RoundedBorder.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 6/3/24.
//

import SwiftUI

struct RoundedBorder: ViewModifier {
    let cornerRadius: CGFloat
    let color: Color
    
    func body(content: Content) -> some View {
        content.overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(color)
        }
    }
}

extension View {
    func roundedBorder(cornerRadius: CGFloat, color: Color) -> some View {
        modifier(RoundedBorder(cornerRadius: cornerRadius, color: color))
    }
}
