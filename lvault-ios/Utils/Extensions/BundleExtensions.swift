//
//  BundleExtensions.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/14/25.
//

import Foundation

extension Bundle {
    func get<T>(_ key: Bundle.Key) -> T? {
        return infoDictionary?[key.rawValue] as? T
    }
    
    func unsafeGet<T>(_ key: Bundle.Key) -> T {
        return infoDictionary![key.rawValue] as! T
    }
}

extension Bundle {
    enum Key: String {
        case versionNumber = "CFBundleShortVersionString"
        case buildNumber = "CFBundleVersion"
        case apiClientId = "CLIENT_ID"
        case apiClientSecret = "CLIENT_SECRET"
        case apiBaseUrl = "API_BASE_URL"
    }
}
