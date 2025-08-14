//
//  ScanDocResponse.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/14/25.
//

struct ScanDocResultItem: Decodable {
    let amount: Double
    let timestamp: Double
    let note: String?
//    let labelIds: [String]
}

struct ScanDocResponse: Decodable {
    var data: [ScanDocResultItem]
}
