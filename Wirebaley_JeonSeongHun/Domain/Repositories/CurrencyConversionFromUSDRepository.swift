//
//  CurrenyConversionRepository.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

protocol CurrencyConversionFromUSDRepository {
    func fetchCurrencys(currencies: [String], source: String) async throws -> CurrenciesFromUSD
}
