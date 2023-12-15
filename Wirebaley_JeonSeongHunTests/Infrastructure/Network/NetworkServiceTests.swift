//
//  NetworkServiceTests.swift
//  Wirebaley_JeonSeongHunTests
//
//  Created by 전성훈 on 2023/12/15.
//

import XCTest

@testable import Wirebaley_JeonSeongHun

private struct MockEndpoint: RequestTable {
    var path: String
    var method: HTTPMethodType
    var headerParameters: [String : String]? = [:]
    var queryParametersEncodable: Encodable?
    var queryParameters: [String : Any] = [:]
    var bodyParametersEncodable: Encodable?
    var bodyParameters: [String : Any] = [:]
    var bodyEncoder: BodyEncoder = JSONBodyEncoder()
    
    init(path: String, method: HTTPMethodType) {
        self.path = path
        self.method = method
    }
}

private enum MockNetworkError: Error, Equatable {
    case networkError(statusCode: Int, data: Data?)
    case notConnected
}

private final class MockNetworkConfigurable: NetworkConfigurable {
    var baseURL: URL = URL(string: "http://test.com")!
    var headers: [String : String] = [:]
    var queryParameters: [String : String] = [:]
}

private final class MockNetworkSessionManager: NetworkSessionManager {
    var response: HTTPURLResponse?
    var data: Data = Data()
    var error: Error?
    
    var isReturnError = false

    func request(_ request: URLRequest) async throws -> Data {
        if isReturnError {
            throw MockNetworkError.notConnected
        }
        
        guard let httpResponse = response,
              200...299 ~= httpResponse.statusCode else {
            throw MockNetworkError.networkError(
                statusCode: (response)?.statusCode ?? 0,
                data: data
            )
        }
        
        return data
    }
}

private final class MockNetworkErrorLogger: NetworkErrorLogger {
    var loggedErrors: [Error] = []
    
    func log(responseData data: Data?) { }
    func log(error: Error) { loggedErrors.append(error) }
}

final class NetworkServiceTests: XCTestCase {
    private var networkService: DefaultNetworkService!
    
    private var mockNetworkConfigurable: MockNetworkConfigurable!
    private var mockNetworkSessionManager: MockNetworkSessionManager!
    private var mockNetworkErrorLogger: MockNetworkErrorLogger!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockNetworkConfigurable = MockNetworkConfigurable()
        mockNetworkSessionManager = MockNetworkSessionManager()
        mockNetworkErrorLogger = MockNetworkErrorLogger()
    }

    override func tearDownWithError() throws {
        mockNetworkConfigurable = nil
        mockNetworkSessionManager = nil
        mockNetworkErrorLogger = nil
        
        networkService = nil
        
        try super.tearDownWithError()
    }
    
    func test_정상적인_응답확인() async {
        // given
        let expectedResponseData = "Data".data(using: .utf8)!
        mockNetworkSessionManager.data = expectedResponseData
        mockNetworkSessionManager.response = HTTPURLResponse(
            url: URL(string: "http://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        networkService = DefaultNetworkService(
            config: mockNetworkConfigurable,
            sessionManager: mockNetworkSessionManager,
            logger: mockNetworkErrorLogger
        )
                
        var data = Data()
        // when
        do {
            data = try await networkService.request(
                endPoint: MockEndpoint(
                    path: "http://test.com",
                    method: .get
                )
            )
        } catch { }
        
        // then
        XCTAssertEqual(data, expectedResponseData)
    }
    
    func test_상태코드_400이상_응답확인() async {
        // given
        let expectedResponseData = "Data".data(using: .utf8)!
        mockNetworkSessionManager.data = expectedResponseData
        mockNetworkSessionManager.response = HTTPURLResponse(
            url: URL(string: "http://test.com")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )

        networkService = DefaultNetworkService(
            config: mockNetworkConfigurable,
            sessionManager: mockNetworkSessionManager,
            logger: mockNetworkErrorLogger
        )
        var resultStatusCode: Int!
        
        // when
        do {
            let _ = try await networkService.request(
                endPoint: MockEndpoint(
                    path: "http://test.com",
                    method: .get
                )
            )
        } catch let error as MockNetworkError {
            if case .networkError(
                statusCode: let statusCode,
                data: _
            ) = error {
                resultStatusCode = statusCode
            }
        } catch { }

        
        XCTAssertEqual(resultStatusCode, 400)
    }
    
    func test_네트워크_연결_안되어있을때() async {
        // given
        let expectedResponseData = "Data".data(using: .utf8)!
        mockNetworkSessionManager.data = expectedResponseData
        mockNetworkSessionManager.response = nil
        mockNetworkSessionManager.error = MockNetworkError.notConnected
        mockNetworkSessionManager.isReturnError = true

        networkService = DefaultNetworkService(
            config: mockNetworkConfigurable,
            sessionManager: mockNetworkSessionManager,
            logger: mockNetworkErrorLogger
        )
        var resultError : MockNetworkError!

        // when
        do {
            let _ = try await networkService.request(
                endPoint: MockEndpoint(
                    path: "http://test.com",
                    method: .get
                )
            )
        } catch let error as MockNetworkError {
            resultError = error
        } catch { }
        
        // then
        XCTAssertEqual(resultError, MockNetworkError.notConnected)

    }
}
