//
//  OCRResult.swift
//  lvault-ios
//
//  Created by Claude on 8/12/25.
//

import Foundation
import CoreGraphics

struct OCRResult {
    let text: String
    let boundingBox: CGRect
    let confidence: Float
}

struct OCRResponse {
    let results: [OCRResult]
    let imageSize: CGSize
}