//
//  AppConfiguration.swift
//  wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/13.
//

import Foundation

final class AppConfiguration {
    var apiKey: String? {
        guard let path = Bundle.main.url(forResource: "API", withExtension: "plist") else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: path)
            if let dict = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
                return dict["access_key"] as? String
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    let apiBaseURL = "http://apilayer.net/api"
}
