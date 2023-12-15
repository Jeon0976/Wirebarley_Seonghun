//
//  AppDIContainer.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

final class AppDIContainer {
    lazy var appConfiguration = AppConfiguration()
    
    lazy var apiDataTransferService: DataTransferService = {
        let config = APIDataNetworkConfig(baseURL: URL(string: appConfiguration.apiBaseURL)!, queryParameters: ["access_key": appConfiguration.apiKey ?? "", "format": "1"])
        
        let apiDataNetwork = DefaultNetworkService(config: config)
        
        return DefaultDataTransferService(networkService: apiDataNetwork)
    }()
    
    func makeCurrencyConversionDIContainer() -> CurrencyConversionDIContainer {
        
        let dependencies = CurrencyConversionDIContainer.Dependencies(apiDataTransferService: apiDataTransferService)
        
        return CurrencyConversionDIContainer(dependencies: dependencies)
    }
}
