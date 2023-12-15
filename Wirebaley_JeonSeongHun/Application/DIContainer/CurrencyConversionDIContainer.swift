//
//  CurrencyConversionDIContainer.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import UIKit

final class CurrencyConversionDIContainer {
    struct Dependencies {
        let apiDataTransferService: DataTransferService
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
}

// MARK: Domain
extension CurrencyConversionDIContainer {
    func makeCurrencyConversionFromUSDUseCase() 
    -> CurrencyConversionFromUSDUseCase {
        DefaultCurrencyConversionFromUSDUseCase(
            currencyConversionFromUSDRepository: makeCurrencyConversionFromUSDRepository()
        )
    }
}

// MARK: Data
extension CurrencyConversionDIContainer {
    func makeCurrencyConversionFromUSDRepository() 
    -> CurrencyConversionFromUSDRepository {
        DefaultCurrencyConversionFromUSDRepository(
            dataTransferService: dependencies.apiDataTransferService
        )
    }
}

// MARK: Presentation
extension CurrencyConversionDIContainer {
    @MainActor func makeCurrencyConversionViewController()
    -> CurrencyConversionViewController {
        CurrencyConversionViewController.create(
            with: makeCurrencyConversionViewModel()
        )
    }
    
    @MainActor func makeCurrencyConversionViewModel() 
    -> CurrencyConversionViewModel {
        CurrencyConversionViewModel(
            currencyConversionFromUSDUseCase: makeCurrencyConversionFromUSDUseCase()
        )
    }
}
