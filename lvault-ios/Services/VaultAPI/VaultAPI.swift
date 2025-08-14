//
//  VaultAPI.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/14/25.
//

import Alamofire
import Foundation

typealias HttpMethod = HTTPMethod

struct VaultAPI<RequestType: Encodable, ResponseType: Decodable, ErrorType: Error> {
    let url: String
    let method: HttpMethod
    
    fileprivate init(url: String, method: HttpMethod) {
        self.url = url
        self.method = method
    }
}

enum VaultAPIs {
    private static let baseUrl: String = Bundle.main.unsafeGet(.apiBaseUrl)
    
    static let scanDoc: VaultAPI<ScanDocRequest, ScanDocResponse, ApiError> = .init(
        url: "\(baseUrl)/api/v1/scan-doc",
        method: .post
    )
}
