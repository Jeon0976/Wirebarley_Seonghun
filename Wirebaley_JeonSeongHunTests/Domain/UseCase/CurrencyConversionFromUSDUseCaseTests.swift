//
//  CurrencyConversionFromUSDUseCaseTests.swift
//  Wirebaley_JeonSeongHunTests
//
//  Created by 전성훈 on 2023/12/15.
//

import XCTest

@testable import Wirebaley_JeonSeongHun

private enum MockError: Error {
    case failedFetcing
}

private let currenciesFromUSD: CurrenciesFromUSD = CurrenciesFromUSD(
    source: "USD",
    KRW: 10.00, 
    JPY: 10.00,
    PHP: 10.00
)

private final class MockCurrencyConversionFromUSDRepository: CurrencyConversionFromUSDRepository {
    var mockCurrenciesFromUSD = currenciesFromUSD
    var isReturnError = false
    
    func fetchCurrencys(
        currencies: [String],
        source: String
    ) async throws -> CurrenciesFromUSD {
        if isReturnError {
            throw MockError.failedFetcing
        }
        
        return mockCurrenciesFromUSD
    }
}

final class CurrencyConversionFromUSDUseCaseTests: XCTestCase {
    private var usecase: DefaultCurrencyConversionFromUSDUseCase!
    private var repository: MockCurrencyConversionFromUSDRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        repository = MockCurrencyConversionFromUSDRepository()
        
        usecase = DefaultCurrencyConversionFromUSDUseCase(
            currencyConversionFromUSDRepository: repository
        )
    }

    override func tearDownWithError() throws {
        repository = nil 
        usecase = nil
        
        try super.tearDownWithError()
    }
    
    func test_CurrenicesFromUSD_Fetch_성공할때() async {
        // given
        let requestValue = CurrencyConversionRequestValue(
            source: "USD",
            currencies: ["KRW", "JPY", "PHP"]
        )
        
        var result: CurrenciesFromUSD?
        
        // when
        do {
            result = try await usecase.execute(requestValue: requestValue)
        } catch { }
        
        // then
        XCTAssertEqual(result, currenciesFromUSD)
    }
    
    func test_CurrenicesFromUSD_Fetch_실패할때() async {
        // given
        let requestValue = CurrencyConversionRequestValue(
            source: "USD",
            currencies: ["KRW", "JPY", "PHP"]
        )
        repository.isReturnError = true
        var resultError: MockError?
        
        // when
        do {
            let _ = try await usecase.execute(requestValue: requestValue)
        } catch let error as MockError {
            resultError = error
        } catch { }
        
        // then
        XCTAssertEqual(resultError, MockError.failedFetcing)
    }
}
