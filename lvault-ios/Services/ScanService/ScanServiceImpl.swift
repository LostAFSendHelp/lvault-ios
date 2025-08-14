//
//  ScanServiceImpl.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/16/25.
//

import Foundation
import Combine

class ScanServiceImpl: ScanService {
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient = ApiClient()) {
        self.apiClient = apiClient
    }
    
    func scanDoc(request: ScanDocRequest) -> AnyPublisher<[TransactionSuggestion], Error> {
        return Future<[TransactionSuggestion], Error> { promise in
            self.apiClient.request(
                api: VaultAPIs.scanDoc,
                params: request
            ) { result in
                switch result {
                case .success(let response):
                    let suggestions = response.data.map { TransactionSuggestion(from: $0) }
                    promise(.success(suggestions))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

