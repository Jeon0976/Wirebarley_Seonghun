//
//  CurrenciesConversionRequestDTO+.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

struct CurrenciesConversionRequestDTO: Encodable, Equatable {
    let currencies: String
    let source: String
}
