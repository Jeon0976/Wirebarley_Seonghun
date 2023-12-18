//
//  CurrencyConversionFromUSDRepositoryTests.swift
//  Wirebaley_JeonSeongHunTests
//
//  Created by 전성훈 on 2023/12/15.
//

import XCTest

@testable import Wirebaley_JeonSeongHun

private final class MockDataTransferService: DataTransferService {
    var response: Any?
    
    func request<T, E>(
        with endponit: E
    ) async throws -> T where T : Decodable, T == E.Response, E : ResponseRequestable {
        return response as! T
    }
}

final class CurrencyConversionFromUSDRepositoryTests: XCTestCase {
    
    func test_API요청확인() {
        // given
        let requestDTO = CurrenciesConversionRequestDTO(
            currencies: "KRW,JPY,PHP",
            source: "USD"
        )
        
        // when 
        let endpoint = APIEndpoints.getCurrencyConversion(with: requestDTO)
        
        // then
        XCTAssertEqual(endpoint.path, "live")
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(
            endpoint.queryParametersEncodable as? CurrenciesConversionRequestDTO,
            requestDTO
        )
    }
    
    func test_fetch_Currencies_확인() async {
        // given
        let mockService = MockDataTransferService()
        
        mockService.response = CurrenciesConversionResponseFromUSDDTO(
            source: "USD",
            quotes: .init(krw: 10.0, jpy: 10.0, php: 10.0)
        )
        let repository = DefaultCurrencyConversionFromUSDRepository(
            dataTransferService: mockService
        )
        let expectedDomain = CurrenciesFromUSD(
            source: "USD",
            KRW: 10.0,
            JPY: 10.0,
            PHP: 10.0
        )
        
        var result: CurrenciesFromUSD?
        
        // when
        do {
            result = try await repository.fetchCurrencys(
                currencies: ["KRW", "JPY", "PHP"],
                source: "USD"
            )
        } catch { }
        
        // then
        XCTAssertEqual(result, expectedDomain)
    }
}
