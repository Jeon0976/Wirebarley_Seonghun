//
//  DefaultCurrencyConversionFromUSDRepository.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

final class DefaultCurrencyConversionFromUSDRepository: CurrencyConversionFromUSDRepository {
    private let dataTransferService: DataTransferService
    
    init(
        dataTransferService: DataTransferService
    ) {
        self.dataTransferService = dataTransferService
    }
    
    func fetchCurrencys(
        currencies: [String],
        source: String
    ) async throws -> CurrenciesFromUSD {
        let currencies = currencies.joined(separator: ",")
        let requestDTO = CurrenciesConversionRequestDTO(
            currencies: currencies,
            source: source
        )
        
        let endPoint = APIEndpoints.getCurrencyConversion(with: requestDTO)
        
        let responseDTO = try await dataTransferService.request(with: endPoint)
        
        return responseDTO.toDomain()
    }
}
