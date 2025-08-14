//
//  OCRServiceStub.swift
//  lvault-ios
//
//  Created by Claude on 8/13/25.
//

import Foundation
import UIKit
import Combine

class OCRServiceStub: OCRService {
    private let shouldFail: Bool
    private let mockResults: [OCRResult]
    
    init(shouldFail: Bool = false, mockResults: [OCRResult] = []) {
        self.shouldFail = shouldFail
        self.mockResults = mockResults.isEmpty ? Self.defaultMockResults : mockResults
    }
    
    func performOCR(on image: UIImage) -> AnyPublisher<OCRResponse, Error> {
        return Future<OCRResponse, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.shouldFail {
                    promise(.failure(OCRError.noTextFound))
                } else {
                    let response = OCRResponse(
                        results: self.mockResults,
                        imageSize: image.size
                    )
                    promise(.success(response))
                }
            }
        }
        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    private static var defaultMockResults: [OCRResult] {
        [
            OCRResult(
                text: "Sample Receipt",
                boundingBox: CGRect(x: 50, y: 20, width: 200, height: 30),
                confidence: 0.95
            ),
            OCRResult(
                text: "$123.45",
                boundingBox: CGRect(x: 180, y: 100, width: 80, height: 25),
                confidence: 0.92
            ),
            OCRResult(
                text: "Total Amount",
                boundingBox: CGRect(x: 50, y: 100, width: 120, height: 25),
                confidence: 0.88
            )
        ]
    }
}
