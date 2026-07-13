//
//  SecretsLoader.swift
//  WeatherWise
//

import Foundation

enum SecretsLoader {
    static func openWeatherMapAPIKey(bundle: Bundle = .main) -> String? {
        guard let path = bundle.path(forResource: "Secrets", ofType: "plist"),
              let secrets = NSDictionary(contentsOfFile: path),
              let key = secrets["OpenWeatherMapAPIKey"] as? String,
              !key.isEmpty,
              key != "YOUR_API_KEY_HERE" else {
            return nil
        }
        return key
    }
}
