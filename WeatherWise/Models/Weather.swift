//
//  Weather.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

struct WeatherResponse: Codable {
    let main: MainWeather
    let weather: [WeatherCondition]
    
    struct MainWeather: Codable {
        let temp: Double
        let feels_like: Double
        let temp_min: Double
        let temp_max: Double
        let humidity: Int
    }
    
    struct WeatherCondition: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
}

