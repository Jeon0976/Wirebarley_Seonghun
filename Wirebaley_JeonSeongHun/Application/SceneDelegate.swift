//
//  SceneDelegate.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/12.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    let appDIContainer = AppDIContainer()
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        /// scene delegate 테스트 코드에서 실행 안되도록하는 조치 ->  역할별 테스트 명확성을 위해
        /// 참고: https://stackoverflow.com/questions/27500940/how-to-let-the-app-know-if-its-running-unit-tests-in-a-pure-swift-project
#if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            window?.rootViewController = UIViewController()
            window?.makeKeyAndVisible()
            
            return
        }
#endif

        let currencyConversionDIContainer = appDIContainer.makeCurrencyConversionDIContainer()
        let rootVC = currencyConversionDIContainer.makeCurrencyConversionViewController()
        
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
    }
}

