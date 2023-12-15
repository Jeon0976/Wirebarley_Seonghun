//
//  CurrenciesFromUSD.swift
//  Wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

struct CurrenciesFromUSD: Equatable {
    let source: String
    let KRW: Double
    let JPY: Double
    let PHP: Double
    
    func currencyInfo(for currency: CurrencyReceived) -> CurrencyInfo {
        let rate = self.rate(for: currency)
        let unit = "\(currency.rawValue) / \(source)"
        
        return CurrencyInfo(
            currency: currency,
            rateFromUSD: rate,
            unit: unit
        )
    }
    
    private func rate(for currency: CurrencyReceived) -> Double {
        switch currency {
        case .KRW: return KRW
        case .JPY: return JPY
        case .PHP: return PHP
        }
    }
}

extension CurrenciesFromUSD {
    enum CurrencyReceived: String {
        case KRW
        case JPY
        case PHP
        
        var country: String {
            switch self {
            case .KRW: NSLocalizedString(self.rawValue, comment: "")
            case .JPY: NSLocalizedString(self.rawValue, comment: "")
            case .PHP: NSLocalizedString(self.rawValue, comment: "")
            }
        }
        
        init(rawValue: String) {
            switch rawValue {
            case "KRW": self = .KRW
            case "JPY": self = .JPY
            case "PHP": self = .PHP
            default: self = .KRW
            }
        }
    }
}

extension CurrenciesFromUSD {
    struct CurrencyInfo: Equatable {
        let currency: String
        let country: String
        let rate: Double
        let unit: String
        
        init(
            currency: CurrenciesFromUSD.CurrencyReceived,
            rateFromUSD: Double,
            unit: String
        ) {
            self.currency = currency.rawValue
            self.country = currency.country
            self.rate = rateFromUSD
            self.unit = unit
        }
        
        func exchangedRate() -> String {
            return "\(rate.formatCurrency) \(unit)"
        }
    }
}

