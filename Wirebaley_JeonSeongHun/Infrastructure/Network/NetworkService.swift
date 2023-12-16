//
//  NetworkService.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
}

protocol NetworkService {
    func request(endPoint: RequestTable) async throws -> Data
}

protocol NetworkSessionManager {
    func request(_ request: URLRequest) async throws -> Data
}

protocol NetworkErrorLogger {
    func log(responseData data: Data?)
    func log(error: Error)
}

final class DefaultNetworkService: NetworkService {
    private let config: NetworkConfigurable
    private let sessionManager: NetworkSessionManager
    private let logger: NetworkErrorLogger
    
    init(
        config: NetworkConfigurable,
        sessionManager: NetworkSessionManager = DefaultNetworkSessionManager(),
        logger: NetworkErrorLogger = DefaultNetworkErrorLogger()
    ) {
        self.config = config
        self.sessionManager = sessionManager
        self.logger = logger
    }
    
    func request(endPoint: RequestTable) async throws -> Data {
        do {
            let urlRequest = try endPoint.urlRequest(with: config)
            let data = try await sessionManager.request(urlRequest)
            
            logger.log(responseData: data)
            return data
        } catch {
            logger.log(error: error)
            throw error
        }
    }
}

final class DefaultNetworkSessionManager: NetworkSessionManager {
    func request(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw NetworkError.error(
                statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0,
                data: data
            )
        }
        
        return data
    }
}

final class DefaultNetworkErrorLogger: NetworkErrorLogger {
    func log(error: Error) {
        print("Error: \(error)")
    }
    
    func log(responseData data: Data?) {
        print("Success: \(String(describing: data))")
    }
}
