//
//  DismissKeyboard.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 9/16/25.
//

import SwiftUI
import UIKit

struct DismissKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content.onTapGesture {
            content.dismissKeyboard()
        }
    }
}

extension View {
    func dismissKeyboardOnFocusLoss() -> some View {
        return modifier(DismissKeyboard())
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
