//
//  DataTransferService.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworkFailure(Error)
}

protocol DataTransferService {
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void
    
    func request<T: Decodable, E: ResponseRequestable>(with endponit: E) async throws -> T where E.Response == T
}

protocol DataTransferErrorResolver {
    func resolve(error: NetworkError) -> Error
}

protocol DataTransferErrorLogger {
    func log(error: Error)
}

protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

final class DefaultDataTransferService: DataTransferService {
    private let networkService: NetworkService
    private let errorResolver: DataTransferErrorResolver
    private let errorLogger: DataTransferErrorLogger
    
    init(
        networkService: NetworkService,
        errorResolver: DataTransferErrorResolver = DefaultDataTransferErrorResolver(),
        errorLogger: DataTransferErrorLogger = DefaultDataTransferErrorLogger()
    ) {
        self.networkService = networkService
        self.errorResolver = errorResolver
        self.errorLogger = errorLogger
    }
    
    func request<T, E>(with endponit: E) async throws -> T where T : Decodable, T == E.Response, E : ResponseRequestable {
        do {
            let data = try await networkService.request(endPoint: endponit)
            do {
                return try endponit.responseDecoder.decode(data)
            } catch {
                throw DataTransferError.parsing(error)
            }
        } catch let error as NetworkError {
            throw errorChangeableForDataTransferError(networkError: error)
        } catch {
            throw DataTransferError.resolvedNetworkFailure(error)
        }
    }
    
    private func errorChangeableForDataTransferError(networkError: NetworkError) -> DataTransferError {
        let error =  self.errorResolver.resolve(error: networkError)
        return error is NetworkError ? .networkFailure(networkError) : .resolvedNetworkFailure(error)
    }
}

final class DefaultDataTransferErrorResolver: DataTransferErrorResolver {
    func resolve(error: NetworkError) -> Error {
        return error
    }
}

final class DefaultDataTransferErrorLogger: DataTransferErrorLogger {
    func log(error: Error) {
        print(error)
    }
}

final class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    
    init() { }
    
    func decode<T>(_ data: Data) throws -> T where T : Decodable {
        return try jsonDecoder.decode(T.self, from: data)
    }
}


