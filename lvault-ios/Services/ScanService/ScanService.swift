//
//  ScanService.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/16/25.
//

import Foundation
import Combine

protocol ScanService {
    func scanDoc(request: ScanDocRequest) -> AnyPublisher<[TransactionSuggestion], Error>
}

