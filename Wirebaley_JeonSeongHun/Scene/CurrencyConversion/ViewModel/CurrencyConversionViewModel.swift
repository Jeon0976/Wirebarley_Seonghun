//
//  CurrencyConversionViewModel.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/12.
//

import Foundation

@MainActor
final class CurrencyConversionViewModel {
    private let currencyConversionFromUSDUseCase: CurrencyConversionFromUSDUseCase
    
    private let disposeBag = DisposeBag()
    
    private let source = "USD"
    
    var currencies: [String] = [
        CurrenciesFromUSD.CurrencyReceived.KRW.rawValue,
        CurrenciesFromUSD.CurrencyReceived.JPY.rawValue,
        CurrenciesFromUSD.CurrencyReceived.PHP.rawValue
    ]
    
    // MARK: - Input
    var selectedIndex: Int {
        didSet {
            inputData()
        }
    }
    
    var transferAmount: Int {
        didSet {
            inputData()
        }
    }
    
    // 테스트 코드를 위한 변수
    var onCurrenciesFromUSDUpdated: ((CurrenciesFromUSD) -> Void)?
    private var currenciesFromUSD: CurrenciesFromUSD {
        didSet {
            inputData()
        }
    }

    // MARK: - Output
    
    var selectedRecipientInfo = Observable<CurrenciesFromUSD.CurrencyInfo>(
        CurrenciesFromUSD.CurrencyInfo(
            currency: .KRW,
            rateFromUSD: 0.0,
            unit: "")
    )
    var receivedAmount = Observable<String>("")
    var error = Observable<String>("")
    
    init(
        currencyConversionFromUSDUseCase: CurrencyConversionFromUSDUseCase
    ) {
        self.currencyConversionFromUSDUseCase = currencyConversionFromUSDUseCase
        
        self.transferAmount = 0
        self.selectedIndex = 0
        self.currenciesFromUSD = CurrenciesFromUSD(source: source, KRW: 0.0, JPY: 0.0, PHP: 0.0)
    }
    
    // MARK: - 메소드
    func fetchCurrenciesFromUSD() {
        Task {
            guard let value = try? await currencyConversionFromUSDUseCase.execute(requestValue: .init(source: source, currencies: currencies)) else {
                error.value = NSLocalizedString("Retry", comment: "")
                let errorValue = CurrenciesFromUSD(source: source, KRW: 0.0, JPY: 0.0, PHP: 0.0)
                updateCurrenciesFromUSD(with: errorValue)
                return
            }
            updateCurrenciesFromUSD(with: value)
        }
    }
    
    func updateCurrenciesFromUSD(with currenciesFromUSD: CurrenciesFromUSD) {
        self.currenciesFromUSD = currenciesFromUSD
        onCurrenciesFromUSDUpdated?(currenciesFromUSD)
    }
    
    private func inputData() {
        selectedCountry(at: selectedIndex)
        updateTansferAmount(with: transferAmount)
    }
    
    private func selectedCountry(at index: Int) {
        let recipient = CurrenciesFromUSD.CurrencyReceived(rawValue: currencies[index])
        selectedRecipientInfo.value = currenciesFromUSD.currencyInfo(for: recipient)
    }
    
    private func updateTansferAmount(with amount: Int) {
        let rate = selectedRecipientInfo.value.rate

        let resultAmount = (rate * Double(transferAmount)).formatCurrency + " " + selectedRecipientInfo.value.currency
        
        let result = String(format: NSLocalizedString("ReceivedAmount", comment: ""),
                            resultAmount
        )
        
        receivedAmount.value = result
    }
}
