//
//  Loadable.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import Foundation

enum Loadable<T> {
    case loading, data(T), error(Error)
}
