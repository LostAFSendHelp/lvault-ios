//
//  APIClient.swift
//  lvault-ios
//
//  Created by Chuong Nguyen on 8/14/25.
//

import Foundation
import Alamofire

typealias ApiRequestInterceptor = RequestInterceptor

struct EmptyResponse { }

class ApiClient {
    private lazy var session: Session = .init()
    private let interceptor: ApiRequestInterceptor?
    
    init(interceptor: ApiRequestInterceptor? = nil) {
        self.interceptor = interceptor
    }
    
    func request<RequestType: Encodable, ResponseType: Decodable, ErrorType: Error & Decodable>(
        api: VaultAPI<RequestType, ResponseType, ErrorType>,
        params: RequestType? = nil,
        completion: @escaping ResultHandler<ResponseType>
    ) {
        session.request(
            api.url,
            method: api.method,
            parameters: params,
            encoder: api.method.paramEncoder,
            interceptor: interceptor
        )
        .validate()
        .responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    if ResponseType.self == EmptyResponse.self {
                        completion(.success(EmptyResponse() as! ResponseType))
                        return
                    }
                    
                    let value = try JSONDecoder().decode(ResponseType.self, from: data)
                    completion(.success(value))
                } catch {
                    completion(.failure(LVaultError.custom("Malformed JSON response")))
                }
            case .failure(let error):
                guard let data = response.data else {
                    completion(.failure(LVaultError.custom(error.localizedDescription)))
                    return
                }
                
                do {
                    let apiError = try JSONDecoder().decode(ErrorType.self, from: data)
                    completion(.failure(LVaultError.custom(apiError.localizedDescription)))
                } catch {
                    completion(.failure(LVaultError.custom("Unknown error")))
                }
            }
        }
    }
}

private extension HttpMethod {
    var paramEncoder: ParameterEncoder {
        switch self {
        case .get:
            return URLEncodedFormParameterEncoder.default
        default:
            return JSONParameterEncoder.default
        }
    }
}
