//
//  CurrenciesConversionResponseFromUSDDTO+.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

struct CurrenciesConversionResponseFromUSDDTO: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case source
        case quotes
    }
    
    let source: String
    let quotes: CurrenciesQuotesFromUSDDTO
}

extension CurrenciesConversionResponseFromUSDDTO {
    struct CurrenciesQuotesFromUSDDTO: Decodable, Equatable {
        private enum CodingKeys: String, CodingKey {
            case krw = "USDKRW"
            case jpy = "USDJPY"
            case php = "USDPHP"
        }
        
        let krw: Double
        let jpy: Double
        let php: Double
    }
}

extension CurrenciesConversionResponseFromUSDDTO {
    func toDomain() -> CurrenciesFromUSD {
        return .init(
            source: source,
            KRW: quotes.krw,
            JPY: quotes.jpy,
            PHP: quotes.php
        )
    }
}
