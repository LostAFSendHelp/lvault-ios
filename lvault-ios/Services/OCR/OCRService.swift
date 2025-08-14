//
//  OCRService.swift
//  lvault-ios
//
//  Created by Claude on 8/13/25.
//

import Foundation
import UIKit
import Combine

/// Service for performing Optical Character Recognition (OCR) on images
/// 
/// - Important: OCR operations may be performed on a background queue for optimal performance.
///   The returned publisher may emit results on a background queue, so subscribers should
///   ensure they receive values on the main queue when updating UI elements.
protocol OCRService {
    /// Performs OCR on the provided image
    /// - Parameter image: The UIImage to process for text recognition
    /// - Returns: A publisher that emits OCRResponse on success or Error on failure
    /// - Note: This operation may execute on a background queue for performance reasons
    func performOCR(on image: UIImage) -> AnyPublisher<OCRResponse, Error>
}