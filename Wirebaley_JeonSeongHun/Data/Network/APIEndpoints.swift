//
//  APIEndpoints.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

struct APIEndpoints {
    static func getCurrencyConversion(with currencyConversionRequestDTO: CurrenciesConversionRequestDTO
    ) -> Endpoint<CurrenciesConversionResponseFromUSDDTO> {
        return Endpoint(path: "live",
                        method: .get,
                        queryParametersEncodable: currencyConversionRequestDTO
        )
    }
}
