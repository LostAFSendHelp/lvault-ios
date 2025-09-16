//
//  ScanDocResponse.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/14/25.
//

struct ScanDocResultItem: Decodable {
    let amount: Double
    let timestampString: String
    let note: String?
//    let labelIds: [String]
}

struct ScanDocResponse: Decodable {
    var data: [ScanDocResultItem]
}
