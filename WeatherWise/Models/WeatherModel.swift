//
//  WeatherModel.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import Foundation

struct WeatherModel: Codable, Identifiable {
    let id = UUID()
    let temperature: Double
    let condition: String
    let humidity: Int
    let windSpeed: Double
    let locationName: String
    
    enum CodingKeys: String, CodingKey {
        case temperature, condition, humidity, windSpeed, locationName
    }
    
    var isGoodWeather: Bool {
        temperature >= 65 && temperature <= 77 &&
        humidity < 70 &&
        windSpeed < 12
    }
}
