//
//  CGExtensions.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/17/25.
//

import CoreGraphics

extension CGRect {
    func toBoundingBox() -> BoundingBox {
        return BoundingBox(
            x: origin.x, y: origin.y, width: width, height: height
        )
    }
}

extension CGSize {
    func toImageDimensions() -> ImageDimensions {
        return ImageDimensions(width: width, height: height)
    }
}
