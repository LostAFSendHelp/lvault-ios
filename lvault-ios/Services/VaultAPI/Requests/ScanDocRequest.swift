//
//  ScanDocRequest.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/14/25.
//

import CoreGraphics

struct BoundingBox: Codable {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
}

struct ImageDimensions: Codable {
    let width: CGFloat
    let height: CGFloat
}

struct ScanDocDataItem: Codable {
    let text: String
    let boundingBox: BoundingBox
}

struct ScanDocRequest: Codable {
    let items: [ScanDocDataItem]
    let originalImageDimensions: ImageDimensions
    let labelDict: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case items
        case labelDict = "labels"
        case originalImageDimensions
    }
}
