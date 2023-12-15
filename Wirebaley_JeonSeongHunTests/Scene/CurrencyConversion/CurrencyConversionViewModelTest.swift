//
//  Wirebaley_JeonSeongHunTests.swift
//  Wirebaley_JeonSeongHunTests
//
//  Created by 전성훈 on 2023/12/14.
//

import XCTest

@testable import Wirebaley_JeonSeongHun

private enum MockError: Error {
    case dataError
}

private final class MockCurrencyConversionFromUSDUseCase: CurrencyConversionFromUSDUseCase {
    var mockCurrenciesFromUSD: CurrenciesFromUSD!
    var isReturnError = false
    
    func execute(
        requestValue: CurrencyConversionRequestValue
    ) async throws -> CurrenciesFromUSD {
        if isReturnError {
            throw MockError.dataError
        }
        return mockCurrenciesFromUSD
    }
}

@MainActor
final class CurrencyConversionViewModelTest: XCTestCase {
    private var viewModel: CurrencyConversionViewModel!
    private var mockUseCase: MockCurrencyConversionFromUSDUseCase!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockUseCase = MockCurrencyConversionFromUSDUseCase()
        disposeBag = DisposeBag()
        
        viewModel = CurrencyConversionViewModel(
            currencyConversionFromUSDUseCase: mockUseCase
        )
    }
    
    override func tearDownWithError() throws {
        disposeBag = nil
        mockUseCase = nil
        viewModel = nil
        
        try super.tearDownWithError()
    }
    
    func test_최초데이터_불러오기_성공시() {
        // given
        let expectation = XCTestExpectation(description: "비동기작업")
        let mockCurrenciesFromUSD = CurrenciesFromUSD(
            source: "USD",
            KRW: 1295.519887,
            JPY: 142.277502,
            PHP: 55.693001
        )
        mockUseCase.mockCurrenciesFromUSD = mockCurrenciesFromUSD
        
        let currencyInfoExpected = mockCurrenciesFromUSD.currencyInfo(for: .KRW)
        let receivedAmountExpected = String(
            format: NSLocalizedString("ReceivedAmount", comment: ""),
            "0.00 KRW"
        )
        
        var currencyResult = CurrenciesFromUSD(
            source: "USD",
            KRW: 0.0,
            JPY: 0.0,
            PHP: 0.0
        )
        var currencyInfo = currencyResult.currencyInfo(for: .KRW)
        var receivedAmount: String = ""
        
        viewModel.selectedRecipientInfo
            .subscribe(on: self, disposeBag: disposeBag)
            .onNext { info in
                currencyInfo = info
            }
        
        viewModel.receivedAmount
            .subscribe(on: self, disposeBag: disposeBag)
            .onNext { amount in
                receivedAmount = amount
            }
        
        // when
        viewModel.fetchCurrenciesFromUSD()
        
        viewModel.onCurrenciesFromUSDUpdated = { result in
            currencyResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        // then
        XCTAssertEqual(currencyResult, mockUseCase.mockCurrenciesFromUSD)
        XCTAssertEqual(currencyInfo, currencyInfoExpected)
        XCTAssertEqual(receivedAmount, receivedAmountExpected)
    }
    
    func test_최초데이터_불러오기_실패시() {
        // given
        mockUseCase.isReturnError = true
        var isFirst = true
        
        let expectation = XCTestExpectation(description: "비동기작업")
        let errorExpected = NSLocalizedString("Retry", comment: "")
        
        var error: String = "Test"
        
        viewModel.error
            .subscribe(on: self, disposeBag: disposeBag)
            .onNext { errorString in
                guard !isFirst else {
                    isFirst.toggle()
                    return
                }
                
                error = errorString
                expectation.fulfill()
            }
        
        // when
        viewModel.fetchCurrenciesFromUSD()
        
        wait(for: [expectation], timeout: 3)
        
        // then
        XCTAssertEqual(error, errorExpected)
    }
    
    func test_수취국가_선택시() {
        // given
        let mockCurrenciesFromUSD = CurrenciesFromUSD(
            source: "USD",
            KRW: 1295.519887,
            JPY: 142.277502,
            PHP: 55.693001
        )
        
        let currencyInfoExpected = mockCurrenciesFromUSD.currencyInfo(for: .JPY)
        let receivedAmountExpected = String(
            format: NSLocalizedString("ReceivedAmount", comment: ""),
            "0.00 JPY"
        )
        
        var currencyInfo = mockCurrenciesFromUSD.currencyInfo(for: .KRW)
        var receivedAmount: String = ""
        
        viewModel.updateCurrenciesFromUSD(with: mockCurrenciesFromUSD)
        
        viewModel.selectedRecipientInfo
            .subscribe(on: self, disposeBag: disposeBag)
            .onNext { info in
                currencyInfo = info
            }
        viewModel.receivedAmount
            .subscribe(on: self, disposeBag: disposeBag)
            .onNext { amount in
                receivedAmount = amount
            }
        
        // when
        viewModel.selectedIndex = 1
        
        // then
        XCTAssertEqual(currencyInfo, currencyInfoExpected)
        XCTAssertEqual(receivedAmount, receivedAmountExpected)
    }
    
    func test_송금액_설정시() {
        // given
        let mockCurrenciesFromUSD = CurrenciesFromUSD(
            source: "USD",
            KRW: 1295.519887,
            JPY: 142.277502,
            PHP: 55.693001
        )

        let currencyInfoExpected = mockCurrenciesFromUSD.currencyInfo(for: .PHP)
        let receivedAmountExpected = String(
            format: NSLocalizedString("ReceivedAmount", comment: ""),
            "5,569.30 PHP"
        )
        
        var currencyInfo = mockCurrenciesFromUSD.currencyInfo(for: .KRW)
        var receivedAmount: String = ""
        
        viewModel.updateCurrenciesFromUSD(with: mockCurrenciesFromUSD)
        
        viewModel.selectedRecipientInfo
            .subscribe(on: self, disposeBag: disposeBag)
            .onNext { info in
                currencyInfo = info
            }
        viewModel.receivedAmount
            .subscribe(on: self, disposeBag: disposeBag)
            .onNext { amount in
                receivedAmount = amount
            }
        
        // when
        viewModel.selectedIndex = 2
        viewModel.transferAmount = 100
        
        // then
        XCTAssertEqual(currencyInfo, currencyInfoExpected)
        XCTAssertEqual(receivedAmount, receivedAmountExpected)
    }
}
