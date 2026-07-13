//
//  WeatherModel.swift
//  WeatherWise
//
//  Created by Kshitij Kumar on 1/6/25.
//

import Foundation

struct WeatherModel: Codable, Identifiable, Equatable {
    let id = UUID()
    let temperature: Double
    let condition: String
    let humidity: Int
    let windSpeed: Double
    let locationName: String

    enum CodingKeys: String, CodingKey {
        case temperature, condition, humidity, windSpeed, locationName
    }

    /// Evaluates this reading against user-configured criteria.
    func meets(_ criteria: WeatherCriteria) -> Bool {
        criteria.isSatisfied(temperature: temperature, humidity: humidity, windSpeed: windSpeed)
    }

    /// Convenience using default production thresholds.
    var isGoodWeather: Bool {
        meets(.default)
    }
}

extension WeatherModel {
    static func from(response: OpenWeatherResponse) -> WeatherModel {
        WeatherModel(
            temperature: response.main.temp,
            condition: response.weather.first?.main ?? "Unknown",
            humidity: response.main.humidity,
            windSpeed: response.wind.speed,
            locationName: "\(response.name), \(response.sys.country)"
        )
    }
}
