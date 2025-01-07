//
//  Weather.swift
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
    
    var isGoodWeather: Bool {
        return temperature >= 18 && temperature <= 25 &&
               humidity < 70 &&
               windSpeed < 20
    }
}


