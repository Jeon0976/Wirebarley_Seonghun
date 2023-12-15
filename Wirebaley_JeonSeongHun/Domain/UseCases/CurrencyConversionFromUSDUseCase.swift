//
//  CurrencyConversionUseCase.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

protocol CurrencyConversionFromUSDUseCase {
    func execute(requestValue: CurrencyConversionRequestValue) async throws -> CurrenciesFromUSD
}

struct CurrencyConversionRequestValue {
    let source: String
    let currencies: [String]
}

final class DefaultCurrencyConversionFromUSDUseCase: CurrencyConversionFromUSDUseCase {
    
    private let currencyConversionFromUSDRepository: CurrencyConversionFromUSDRepository
    
    init(
        currencyConversionFromUSDRepository: CurrencyConversionFromUSDRepository
    ) {
        self.currencyConversionFromUSDRepository = currencyConversionFromUSDRepository
    }
    
    func execute(requestValue: CurrencyConversionRequestValue) async throws -> CurrenciesFromUSD {
        return try await currencyConversionFromUSDRepository.fetchCurrencys(
            currencies: requestValue.currencies,
            source: requestValue.source
        )
    }
}
