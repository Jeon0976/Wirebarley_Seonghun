//
//  NetworkSessionManagerTests.swift
//  Wirebaley_JeonSeongHunTests
//
//  Created by 전성훈 on 2023/12/15.
//

import XCTest

@testable import Wirebaley_JeonSeongHun

final class NetworkSessionManagerTests: XCTestCase {
    private var sessionManager: DefaultNetworkSessionManager!
    private let networkMonitor = NetworkMonitor.shared
    
    private let appConfiguration = AppConfiguration()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sessionManager = DefaultNetworkSessionManager()
    }

    override func tearDownWithError() throws {
        sessionManager = nil
        
        try super.tearDownWithError()
    }

    func test_유효한API_호출확인() async throws {
        try XCTSkipUnless(networkMonitor.isReachable)
        
        // given
        let urlString = "\(appConfiguration.apiBaseURL)/live?access_key=\(appConfiguration.apiKey ?? "")&source=USD"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        var data = Data()
        // when
        do {
            data = try await sessionManager.request(request)
        } catch {
            
        }
        
        XCTAssertNotNil(data)
    }
    
    func test_실패API_호출확인() async throws {
        try XCTSkipUnless(networkMonitor.isReachable)
        
        // given
        let urlString = "http://test"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        var networkError: Error?
        // when
        do {
            let _ = try await sessionManager.request(request)
        } catch {
            networkError = error
        }
        
        XCTAssertNotNil(networkError)
    }
}
