//
//  NetworkConfigurable.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

protocol NetworkConfigurable {
    var baseURL: URL { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
}

struct APIDataNetworkConfig: NetworkConfigurable {
    let baseURL: URL
    let headers: [String : String]
    let queryParameters: [String : String]
    
    init(
        baseURL: URL,
        headers: [String : String] = [:],
        queryParameters: [String : String] = [:]
    ) {
        self.baseURL = baseURL
        self.headers = headers
        self.queryParameters = queryParameters
    }
}
