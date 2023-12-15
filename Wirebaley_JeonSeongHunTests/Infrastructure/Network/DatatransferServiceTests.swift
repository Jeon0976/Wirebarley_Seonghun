//
//  DatatransferServiceTests.swift
//  Wirebaley_JeonSeongHunTests
//
//  Created by 전성훈 on 2023/12/15.
//

import XCTest

@testable import Wirebaley_JeonSeongHun

private struct MockModel: Decodable, Equatable {
    let test: String
}

private enum MockDataTransferError: Error {
    case transferError
}

private struct MockNetworkConfigurable: NetworkConfigurable {
    var baseURL: URL = URL(string: "http://test.com")!
    var headers: [String : String] = [:]
    var queryParameters: [String : String] = [:]
}

private struct MockNetworkService: NetworkService {
    let config: NetworkConfigurable
    var mockSessionManager: NetworkSessionManager
        
    init(
        config: NetworkConfigurable,
        mockSessionManager: NetworkSessionManager
    ) {
        self.config = config
        self.mockSessionManager = mockSessionManager
    }
    
    func request(endPoint: RequestTable) async throws -> Data {
        do {
            let urlRequest = try endPoint.urlRequest(with: config)
            let data = try await mockSessionManager.request(urlRequest)
            
            return data
        } catch {
            throw MockDataTransferError.transferError
        }
    }
}

private struct MockNetworkSessionManager: NetworkSessionManager {
    var response: HTTPURLResponse?
    var data: Data = Data()
    var error: Error?
    
    var isReturnError = false

    func request(_ request: URLRequest) async throws -> Data {
        if isReturnError {
            throw MockDataTransferError.transferError
        }
        guard let httpResponse = response,
              200...299 ~= httpResponse.statusCode else {
            throw MockDataTransferError.transferError
        }
        
        return data
    }
}

final class DatatransferServiceTests: XCTestCase {
    
    func test_유효한_JSON데이터_받을때() async {
        // given
        let networkConfig = MockNetworkConfigurable()
        var networkSessionManager = MockNetworkSessionManager()
        
        let responseData = #"{"test": "test"}"#.data(using: .utf8)!
        
        networkSessionManager.response = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        networkSessionManager.data = responseData
        
        var result: MockModel?
        let expectedResult = MockModel(test: "test")

        let networkService = MockNetworkService(config: networkConfig, mockSessionManager: networkSessionManager)
        
        let dataTransfer = DefaultDataTransferService(networkService: networkService)
        
        // when
        do {
            result = try await dataTransfer.request(with: Endpoint<MockModel>(path: "http://test.com", method: .get))
        } catch { }
        
        // then
        XCTAssertEqual(result, expectedResult)
    }
    
    func test_유효하지않은_JSON데이터_받을때() async {
        // given
        let networkConfig = MockNetworkConfigurable()
        var networkSessionManager = MockNetworkSessionManager()
        
        let responseData = #"{"test": 1}"#.data(using: .utf8)!
        
        networkSessionManager.response = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        networkSessionManager.data = responseData
        
        var result: Error?

        let networkService = MockNetworkService(config: networkConfig, mockSessionManager: networkSessionManager)
        
        let dataTransfer = DefaultDataTransferService(networkService: networkService)
        
        // when
        do {
            let _ = try await dataTransfer.request(with: Endpoint<MockModel>(path: "http://test.com", method: .get))
        } catch {
            result = error
        }
        
        // then
        XCTAssertNotNil(result)
    }
}
