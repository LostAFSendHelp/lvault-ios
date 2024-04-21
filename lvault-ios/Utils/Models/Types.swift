//
//  Types.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import Foundation
import Combine

typealias VoidHandler<T> = (T) -> Void
typealias EmptyVoidHandler = () -> Void
typealias DisposeBag = Set<AnyCancellable>
