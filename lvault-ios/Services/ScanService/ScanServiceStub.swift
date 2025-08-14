//
//  ScanServiceStub.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/16/25.
//

import Foundation
import Combine

class ScanServiceStub: ScanService {
    func scanDoc(request: ScanDocRequest) -> AnyPublisher<[TransactionSuggestion], Error> {
        let mockSuggestions = [
            TransactionSuggestion(
                amount: -25.99,
                timestamp: Date().timeIntervalSince1970,
                note: "Coffee purchase",
                labelIds: ["food", "drinks"]
            ),
            TransactionSuggestion(
                amount: -12.50,
                timestamp: Date().addingTimeInterval(-3600).timeIntervalSince1970,
                note: "Lunch",
                labelIds: ["food"]
            )
        ]
        
        return Just(mockSuggestions)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

