//
//  Types.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 4/21/24.
//

import Foundation
import Combine

typealias VoidHandler<T> = (T) -> Void
typealias VoidHandlerThrows<T> = (T) throws -> Void
typealias VoidHandler2<T1, T2> = (T1, T2) -> Void
typealias VoidHandler2Throws<T1, T2> = (T1, T2) throws -> Void
typealias EmptyVoidHandler = () -> Void
typealias DisposeBag = Set<AnyCancellable>

typealias VoidPublisher = AnyPublisher<Void, Never>
typealias DataPublisher<T> = AnyPublisher<T, Never>
