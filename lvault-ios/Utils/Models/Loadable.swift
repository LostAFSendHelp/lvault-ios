//
//  Loadable.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import Foundation

typealias LoadableList<T> = Loadable<[T]>

enum Loadable<T> {
    case loading, data(T), error(Error), idle
    
    var currentData: T? {
        switch self {
        case .data(let current): return current
        default: return nil
        }
    }
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        } else {
            return false
        }
    }
}
