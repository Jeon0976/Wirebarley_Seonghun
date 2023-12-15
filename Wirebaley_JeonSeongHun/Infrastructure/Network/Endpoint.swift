//
//  Endpoint.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

enum HTTPMethodType: String {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol RequestTable {
    var path: String { get }
    var method: HTTPMethodType { get }
    var headerParameters: [String: String]? { get }
    var queryParametersEncodable: Encodable? { get }
    var queryParameters: [String: Any] { get }
    var bodyParametersEncodable: Encodable? { get }
    var bodyParameters: [String: Any] { get }
    var bodyEncoder: BodyEncoder { get }
    
    func urlRequest(with networkConfig: NetworkConfigurable) throws -> URLRequest
}

extension RequestTable {
    func urlRequest(with config: NetworkConfigurable) throws -> URLRequest {
        let url = try self.url(with: config)
        var urlRequest = URLRequest(url: url)
        var allHeaders: [String: String] = config.headers
        
        if let headerParameters = headerParameters {
            headerParameters.forEach { allHeaders.updateValue($1, forKey: $0) }
        }
        
        if let bodyParametersEncodable = bodyParametersEncodable {
            let encodedBody = bodyEncoder.encode(bodyParametersEncodable)
            urlRequest.httpBody = encodedBody
        }
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        
        return urlRequest
    }
    
    private func url(with config: NetworkConfigurable) throws -> URL {
        let baseURL = config.baseURL.absoluteString.last != "/" ? 
        config.baseURL.absoluteString + "/" :
        config.baseURL.absoluteString
        
        let endpoint = baseURL.appending(path)
        
        guard var urlComponents = URLComponents(string: endpoint) else {
            throw RequestGenerationError.components
        }
        
        var urlQueryItmes: [URLQueryItem] = []
        
        /// 기본 query
        config.queryParameters.forEach {
            urlQueryItmes.append(URLQueryItem(
                name: $0.key,
                value: $0.value)
            )
        }
        
        if let queryParametersEncodable = queryParametersEncodable {
            let data = try JSONEncoder().encode(queryParametersEncodable)
            let queryParameters = try JSONSerialization.jsonObject(with: data) 
                as? [String: Any] ?? queryParameters
            
            queryParameters.forEach {
                urlQueryItmes.append(URLQueryItem(
                    name: $0.key,
                    value: "\($0.value)")
                )
            }
        } else {
            /// 추가된 query
            queryParameters.forEach {
                urlQueryItmes.append(URLQueryItem(
                    name: $0.key,
                    value: "\($0.value)")
                )
            }
        }
        
        urlComponents.queryItems = urlQueryItmes
        
        guard let url = urlComponents.url else { throw
            RequestGenerationError.components
        }
        
        return url
    }
}

protocol ResponseRequestable: RequestTable {
    associatedtype Response
    
    var responseDecoder: ResponseDecoder { get }
}

protocol BodyEncoder {
    func encode(_ parameters: Encodable) -> Data?
}

struct JSONBodyEncoder: BodyEncoder {
    func encode(_ parameters: Encodable) -> Data? {
        return try? JSONEncoder().encode(parameters)
    }
}

enum RequestGenerationError: Error {
    case components
}

// MARK: Implemention

final class Endpoint<R>: ResponseRequestable {
    typealias Response = R
    
    let path: String
    let method: HTTPMethodType
    let headerParameters: [String : String]?
    let queryParametersEncodable: Encodable?
    let queryParameters: [String : Any]
    let bodyParametersEncodable: Encodable?
    let bodyParameters: [String : Any]
    let bodyEncoder: BodyEncoder
    
    let responseDecoder: ResponseDecoder
    
    init(
        path: String,
        method: HTTPMethodType,
        headerParameters: [String : String]? = nil,
        queryParametersEncodable: Encodable? = nil,
        queryParameters: [String: Any] = [:],
        bodyParametersEncodable: Encodable? = nil,
        bodyParameters: [String: Any] = [:],
        bodyEncoder: BodyEncoder = JSONBodyEncoder(),
        responseDecoder: ResponseDecoder = JSONResponseDecoder()
    ) {
        self.path = path
        self.method = method
        self.headerParameters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
        self.bodyEncoder = bodyEncoder
        self.responseDecoder = responseDecoder
    }
}
