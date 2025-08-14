//
//  OCRServiceImpl.swift
//  lvault-ios
//
//  Created by Claude on 8/13/25.
//

import Foundation
import UIKit
import Vision
import Combine

class OCRServiceImpl: OCRService {
    func performOCR(on image: UIImage) -> AnyPublisher<OCRResponse, Error> {
        return Future<OCRResponse, Error> { promise in
            guard let cgImage = image.cgImage else {
                promise(.failure(OCRError.invalidImage))
                return
            }
            
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    promise(.failure(OCRError.noTextFound))
                    return
                }
                
                let results = observations.compactMap { observation -> OCRResult? in
                    guard let topCandidate = observation.topCandidates(1).first else { return nil }
                    
                    let boundingBox = observation.boundingBox
                    let normalizedRect = CGRect(
                        x: boundingBox.origin.x,
                        y: 1 - boundingBox.origin.y - boundingBox.height,
                        width: boundingBox.width,
                        height: boundingBox.height
                    )
                    
                    let imageRect = CGRect(
                        x: normalizedRect.origin.x * image.size.width,
                        y: normalizedRect.origin.y * image.size.height,
                        width: normalizedRect.width * image.size.width,
                        height: normalizedRect.height * image.size.height
                    )
                    
                    return OCRResult(
                        text: topCandidate.string,
                        boundingBox: imageRect,
                        confidence: topCandidate.confidence
                    )
                }
                
                let response = OCRResponse(
                    results: results,
                    imageSize: image.size
                )
                
                promise(.success(response))
            }
            
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US", "vi-VN"]
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

enum OCRError: LocalizedError {
    case invalidImage
    case noTextFound
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image provided for OCR processing"
        case .noTextFound:
            return "No text found in the image"
        }
    }
}